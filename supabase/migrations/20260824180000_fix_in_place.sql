-- ============================================================================
-- Bring the existing schema to the target state — WITHOUT dropping anything
-- ============================================================================
--
-- This replaces the earlier drop-and-recreate migration. That one made sense
-- when the database was throwaway; it isn't any more — there is real response
-- data, and RLS has since been partly configured by hand. This migration is
-- additive and idempotent: run it as many times as you like.
--
-- It is also urgent. RLS is currently half-applied:
--   · SELECT is correctly scoped to the owner   (good — read privacy is fixed)
--   · answers has NO insert policy               (submitting a survey is broken)
--   · survey_responses accepts anonymous inserts (anyone can forge completions)
--
-- The app cannot submit a survey until section 5 of this file exists.
--
-- Run it in the Supabase dashboard: SQL Editor -> New query -> paste -> Run.
-- ============================================================================


-- ─────────────────────────────────────────────────────────────────────────────
-- 1 · Columns the app expects
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.options
  add column if not exists order_index integer not null default 0;

alter table public.questions
  add column if not exists is_required boolean not null default true;

alter table public.surveys
  add column if not exists is_published boolean not null default true;

create index if not exists options_question_order
  on public.options (question_id, order_index);

create index if not exists questions_survey_order
  on public.questions (survey_id, order_index);

-- Seed options ordering deterministically (they are all 0 today).
with numbered as (
  select id, row_number() over (partition by question_id order by id) - 1 as rn
  from public.options
)
update public.options o
set order_index = n.rn
from numbered n
where o.id = n.id and o.order_index = 0;


-- ─────────────────────────────────────────────────────────────────────────────
-- 2 · Clean up junk rows
-- ─────────────────────────────────────────────────────────────────────────────

-- Responses with no answers at all. Each one silently counts toward the points
-- balance while recording nothing. Four of these exist right now: two created
-- by the old client, two created by my own verification runs against the live
-- project after the answers insert policy disappeared mid-session and the
-- compensating delete could no longer fire. I could not remove them myself —
-- DELETE is blocked by RLS and returns 204 having affected zero rows.
delete from public.survey_responses r
where not exists (select 1 from public.answers a where a.response_id = r.id);

-- Responses belonging to user ids that do not exist in auth.users — leftovers
-- from the hardcoded-UUID era.
delete from public.survey_responses r
where not exists (select 1 from auth.users u where u.id = r.user_id);

-- Keep one response per (survey, user): the one with the most answers.
delete from public.survey_responses r
where r.id not in (
  select distinct on (survey_id, user_id) id
  from public.survey_responses
  order by survey_id, user_id,
           (select count(*) from public.answers a where a.response_id = survey_responses.id) desc,
           created_at asc
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 3 · Drop answer rows the old client wrote into the wrong column
-- ─────────────────────────────────────────────────────────────────────────────
--
-- single_choice answers had their option UUID written into text_answer, because
-- the old code picked the column from the value's runtime type and an option id
-- is a String exactly like a free-text answer is. Those rows can never be
-- joined to `options`, so any aggregate over choice answers silently omits
-- them — worse than having no row at all, because they look like data.
--
-- Deleting rather than migrating: the values are from a single test response,
-- and a rule-based delete cannot mistake a genuine free-text answer for a
-- misplaced option id the way a rule-based UPDATE might.
--
-- Expressed as a rule, not as a list of ids, so it also catches anything else
-- of the same shape.

delete from public.answers a
using public.questions q
where q.id = a.question_id
  and q.type in ('single_choice', 'multiple_choice')
  and a.text_answer is not null;

-- The mirror of the above: a text question whose value ended up in a choice
-- column. None exist today; the rule costs nothing and closes the gap.
delete from public.answers a
using public.questions q
where q.id = a.question_id
  and q.type in ('short', 'long', 'email', 'phone')
  and a.text_answer is null
  and (a.option_id is not null or a.option_ids is not null);


-- ─────────────────────────────────────────────────────────────────────────────
-- 4 · Author the missing choice options
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Seven choice questions across three surveys have no options, which makes them
-- unanswerable. These are reasonable defaults — edit the labels to taste, but
-- the surveys are broken without something here.

insert into public.options (question_id, order_index, label)
select q.id, v.ord, v.label
from (values
  -- E-Commerce · How often do you shop online?
  ('177dfc56-8694-4301-be88-7f04e08128de', 0, 'Several times a week'),
  ('177dfc56-8694-4301-be88-7f04e08128de', 1, 'About once a week'),
  ('177dfc56-8694-4301-be88-7f04e08128de', 2, 'A few times a month'),
  ('177dfc56-8694-4301-be88-7f04e08128de', 3, 'A few times a year'),
  ('177dfc56-8694-4301-be88-7f04e08128de', 4, 'Almost never'),
  -- E-Commerce · Preferred payment method
  ('fb730c99-c901-48ab-919e-0e414e336d66', 0, 'Credit or debit card'),
  ('fb730c99-c901-48ab-919e-0e414e336d66', 1, 'PayPal'),
  ('fb730c99-c901-48ab-919e-0e414e336d66', 2, 'Mobile wallet'),
  ('fb730c99-c901-48ab-919e-0e414e336d66', 3, 'Bank transfer'),
  ('fb730c99-c901-48ab-919e-0e414e336d66', 4, 'Cash on delivery'),
  -- E-Commerce · Categories shopped for most
  ('c324f769-781d-4465-b5a8-dc5c599276c8', 0, 'Clothing and shoes'),
  ('c324f769-781d-4465-b5a8-dc5c599276c8', 1, 'Electronics'),
  ('c324f769-781d-4465-b5a8-dc5c599276c8', 2, 'Groceries'),
  ('c324f769-781d-4465-b5a8-dc5c599276c8', 3, 'Home and furniture'),
  ('c324f769-781d-4465-b5a8-dc5c599276c8', 4, 'Health and beauty'),
  ('c324f769-781d-4465-b5a8-dc5c599276c8', 5, 'Books and media'),
  -- Product Feedback · How did you hear about us?
  ('df656399-037d-451f-95b5-02bc1d93375d', 0, 'Search engine'),
  ('df656399-037d-451f-95b5-02bc1d93375d', 1, 'Social media'),
  ('df656399-037d-451f-95b5-02bc1d93375d', 2, 'A friend or colleague'),
  ('df656399-037d-451f-95b5-02bc1d93375d', 3, 'An advertisement'),
  ('df656399-037d-451f-95b5-02bc1d93375d', 4, 'Somewhere else'),
  -- Product Feedback · Features used most
  ('ee655ddc-dac4-4501-abd2-5e9aaf5693b9', 0, 'The dashboard'),
  ('ee655ddc-dac4-4501-abd2-5e9aaf5693b9', 1, 'Reports and exports'),
  ('ee655ddc-dac4-4501-abd2-5e9aaf5693b9', 2, 'Notifications'),
  ('ee655ddc-dac4-4501-abd2-5e9aaf5693b9', 3, 'Integrations'),
  ('ee655ddc-dac4-4501-abd2-5e9aaf5693b9', 4, 'The mobile app'),
  -- Employee Satisfaction · Department
  ('a31daca1-f717-498b-939a-88deb00811c6', 0, 'Engineering'),
  ('a31daca1-f717-498b-939a-88deb00811c6', 1, 'Sales'),
  ('a31daca1-f717-498b-939a-88deb00811c6', 2, 'Marketing'),
  ('a31daca1-f717-498b-939a-88deb00811c6', 3, 'Operations'),
  ('a31daca1-f717-498b-939a-88deb00811c6', 4, 'People and HR'),
  ('a31daca1-f717-498b-939a-88deb00811c6', 5, 'Finance'),
  -- Employee Satisfaction · Benefits valued most
  ('8b6b4d13-fa01-4c67-8ab0-f04653ef392e', 0, 'Health insurance'),
  ('8b6b4d13-fa01-4c67-8ab0-f04653ef392e', 1, 'Flexible hours'),
  ('8b6b4d13-fa01-4c67-8ab0-f04653ef392e', 2, 'Working remotely'),
  ('8b6b4d13-fa01-4c67-8ab0-f04653ef392e', 3, 'Paid time off'),
  ('8b6b4d13-fa01-4c67-8ab0-f04653ef392e', 4, 'A learning budget'),
  ('8b6b4d13-fa01-4c67-8ab0-f04653ef392e', 5, 'Retirement contributions')
) as v(question_id, ord, label)
join public.questions q on q.id = v.question_id::uuid
where not exists (
  select 1 from public.options o where o.question_id = q.id
);

-- ── 4b · Author the missing "Health & Wellness" questions ───────────────────
--
-- The survey row exists, is offered to users, and has no questions at all —
-- length claimed 6, the table held 0. These six match its stated subject
-- (habits, physical activity, mental well-being), its 20-minute duration and
-- its 25-point reward, and cover every question type the app renders.
--
-- Guarded on the survey still being empty, so re-running never duplicates them
-- and your own edits are never overwritten.

with target as (
  select s.id
  from public.surveys s
  where s.id = 'ada3e611-fcc2-44c6-8dbb-d565c38a502a'
    and not exists (select 1 from public.questions q where q.survey_id = s.id)
),
inserted as (
  insert into public.questions
    (survey_id, order_index, title, description, type, is_required,
     min, max, divisions, max_length)
  select t.id, v.ord, v.title, v.descr, v.qtype, v.required,
         v.qmin, v.qmax, v.divs, v.maxlen
  from target t
  cross join (values
    (0, 'How many days a week do you exercise?',
        'Anything that gets you moving for 20 minutes or more counts.',
        'slider', true, 0::double precision, 7::double precision, 7, null::integer),
    (1, 'How would you rate your sleep quality?',
        '0 is very poor, 10 is excellent.',
        'slider', true, 0::double precision, 10::double precision, 10, null::integer),
    (2, 'Which of these do you do to manage stress?',
        null,
        'multiple_choice', true, null::double precision, null::double precision, null::integer, null::integer),
    (3, 'How often do you eat a home-cooked meal?',
        null,
        'single_choice', true, null::double precision, null::double precision, null::integer, null::integer),
    (4, 'Roughly how many hours do you sleep on a weeknight?',
        'A decimal is fine — 7.5, for instance.',
        'decimal', true, null::double precision, null::double precision, null::integer, 4),
    (5, 'What is the biggest obstacle to living more healthily?',
        'Optional, but the most useful answer in the survey.',
        'long', false, null::double precision, null::double precision, null::integer, 400)
  ) as v(ord, title, descr, qtype, required, qmin, qmax, divs, maxlen)
  returning id, order_index
)
insert into public.options (question_id, order_index, label)
select i.id, v.ord, v.label
from inserted i
join (values
  -- q2 · stress management (multiple_choice)
  (2, 0, 'Exercise'),
  (2, 1, 'Time outdoors'),
  (2, 2, 'Meditation or breathing'),
  (2, 3, 'Talking to someone'),
  (2, 4, 'Hobbies or creative work'),
  (2, 5, 'Nothing in particular'),
  -- q3 · home-cooked meals (single_choice)
  (3, 0, 'Most days'),
  (3, 1, 'A few times a week'),
  (3, 2, 'About once a week'),
  (3, 3, 'Rarely'),
  (3, 4, 'Almost never')
) as v(q_ord, ord, label) on v.q_ord = i.order_index;


-- Any survey still left with no questions is taken out of circulation. After
-- section 4b below this should match nothing, but it is the backstop that stops
-- an empty survey ever reaching the app again.
update public.surveys
set is_published = false
where not exists (
  select 1 from public.questions q where q.survey_id = surveys.id
);

-- surveys.length disagrees with reality (6 vs 0 for Health & Wellness). Make it
-- true, and keep it true.
update public.surveys s
set length = (select count(*) from public.questions q where q.survey_id = s.id);

create or replace function public.sync_survey_length()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_survey_id uuid := coalesce(new.survey_id, old.survey_id);
begin
  update public.surveys s
  set length = (select count(*) from public.questions q where q.survey_id = v_survey_id)
  where s.id = v_survey_id;
  return null;
end; $$;

drop trigger if exists questions_sync_survey_length on public.questions;
create trigger questions_sync_survey_length
  after insert or delete or update of survey_id on public.questions
  for each row execute function public.sync_survey_length();


-- ─────────────────────────────────────────────────────────────────────────────
-- 5 · The write path — this is what unbreaks submission
-- ─────────────────────────────────────────────────────────────────────────────

-- One response per user per survey, enforced rather than hoped for.
create unique index if not exists survey_responses_one_per_user
  on public.survey_responses (survey_id, user_id);

create unique index if not exists answers_one_per_question
  on public.answers (response_id, question_id);

alter table public.survey_responses alter column user_id set default auth.uid();

create or replace function public.get_available_surveys()
returns setof public.surveys
language sql stable security invoker set search_path = public
as $$
  select s.*
  from public.surveys s
  where s.is_published
    and exists (select 1 from public.questions q where q.survey_id = s.id)
    and not exists (
      select 1 from public.survey_responses r
      where r.survey_id = s.id and r.user_id = auth.uid()
    )
  order by s.created_at desc;
$$;

grant execute on function public.get_available_surveys() to authenticated;

-- Response + answers in one transaction, with the identity taken from the JWT
-- and every question and option validated against the survey being submitted.
-- SECURITY DEFINER so it can write to tables the caller has no insert policy on
-- — which, after section 6, is all of them.
create or replace function public.submit_survey(
  p_survey_id uuid,
  p_answers   jsonb
)
returns jsonb
language plpgsql security definer set search_path = public, pg_temp
as $$
declare
  v_user_id     uuid := auth.uid();
  v_reward      integer;
  v_response_id uuid;
  v_balance     integer;
  v_offenders   text;
begin
  if v_user_id is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    raise exception 'malformed_payload' using errcode = '22023';
  end if;

  select s.reward into v_reward
  from public.surveys s
  where s.id = p_survey_id and s.is_published;

  if not found then
    raise exception 'survey_not_found' using errcode = 'P0002';
  end if;

  -- every answered question must belong to THIS survey
  select string_agg(distinct x.question_id::text, ', ') into v_offenders
  from (
    select (e ->> 'question_id')::uuid as question_id
    from jsonb_array_elements(p_answers) e
  ) x
  left join public.questions q on q.id = x.question_id and q.survey_id = p_survey_id
  where q.id is null;

  if v_offenders is not null then
    raise exception 'question_not_in_survey: %', v_offenders using errcode = '22023';
  end if;

  -- every required question must be answered
  select string_agg(q.id::text, ', ') into v_offenders
  from public.questions q
  where q.survey_id = p_survey_id
    and q.is_required
    and not exists (
      select 1 from jsonb_array_elements(p_answers) e
      where (e ->> 'question_id')::uuid = q.id
    );

  if v_offenders is not null then
    raise exception 'missing_required_answers: %', v_offenders using errcode = '23502';
  end if;

  -- every option id must belong to the question it is attached to.
  -- `multi` is materialized so the lateral only sees entries already known to
  -- hold a JSON array; jsonb_array_elements_text() raises on a scalar.
  with entries as (
    select (e ->> 'question_id')::uuid as question_id, e as body
    from jsonb_array_elements(p_answers) e
  ),
  multi as materialized (
    select question_id, body -> 'option_ids' as ids
    from entries where jsonb_typeof(body -> 'option_ids') = 'array'
  ),
  referenced as (
    select question_id, (body ->> 'option_id')::uuid as option_id
    from entries where body ->> 'option_id' is not null
    union all
    select m.question_id, chosen.value::uuid
    from multi m cross join lateral jsonb_array_elements_text(m.ids) as chosen(value)
  )
  select string_agg(distinct r.option_id::text, ', ') into v_offenders
  from referenced r
  left join public.options o on o.id = r.option_id and o.question_id = r.question_id
  where o.id is null;

  if v_offenders is not null then
    raise exception 'invalid_option: %', v_offenders using errcode = '22023';
  end if;

  begin
    insert into public.survey_responses (survey_id, user_id)
    values (p_survey_id, v_user_id)
    returning id into v_response_id;
  exception when unique_violation then
    raise exception 'already_submitted' using errcode = '23505';
  end;

  insert into public.answers (
    response_id, question_id, text_answer, number_answer, option_id, option_ids
  )
  select
    v_response_id,
    (e ->> 'question_id')::uuid,
    nullif(e ->> 'text_answer', ''),
    (e ->> 'number_answer')::numeric,
    (e ->> 'option_id')::uuid,
    case when jsonb_typeof(e -> 'option_ids') = 'array'
         then array(select jsonb_array_elements_text(e -> 'option_ids'))::uuid[]
    end
  from jsonb_array_elements(p_answers) e;

  -- The balance is derived from completed surveys rather than stored, so there
  -- is no counter to increment here and nothing to drift.
  select coalesce(sum(s.reward), 0) into v_balance
  from public.survey_responses r
  join public.surveys s on s.id = r.survey_id
  where r.user_id = v_user_id;

  return jsonb_build_object(
    'response_id',    v_response_id,
    'reward',         v_reward,
    'points_balance', v_balance
  );
end;
$$;

revoke all on function public.submit_survey(uuid, jsonb) from public, anon;
grant execute on function public.submit_survey(uuid, jsonb) to authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 6 · Close the write hole
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Right now anon can INSERT into survey_responses. The publishable key ships
-- inside the APK, and the points balance is derived from completed responses,
-- so anyone who unzips the app can award themselves whatever they like.
--
-- After this, no role can write these tables directly; submit_survey() is the
-- only path in, and it validates before it writes.

alter table public.survey_responses enable row level security;
alter table public.answers          enable row level security;

drop policy if exists survey_responses_insert     on public.survey_responses;
drop policy if exists survey_responses_insert_own on public.survey_responses;
drop policy if exists answers_insert              on public.answers;
drop policy if exists answers_insert_own          on public.answers;

drop policy if exists survey_responses_read_own on public.survey_responses;
create policy survey_responses_read_own on public.survey_responses
  for select to authenticated using (user_id = auth.uid());

drop policy if exists answers_read_own on public.answers;
create policy answers_read_own on public.answers
  for select to authenticated using (
    exists (
      select 1 from public.survey_responses r
      where r.id = answers.response_id and r.user_id = auth.uid()
    )
  );

revoke insert, update, delete on public.survey_responses from anon, authenticated;
revoke insert, update, delete on public.answers          from anon, authenticated;


-- ─────────────────────────────────────────────────────────────────────────────
-- 7 · What you should see afterwards
-- ─────────────────────────────────────────────────────────────────────────────

select s.title, s.duration, s.reward, s.length as questions, s.is_published,
       (select count(*) from public.questions q
         where q.survey_id = s.id
           and q.type in ('single_choice', 'multiple_choice')
           and not exists (select 1 from public.options o where o.question_id = q.id)
       ) as choice_questions_without_options
from public.surveys s
order by s.created_at;

select r.id, u.email, s.title,
       (select count(*) from public.answers a where a.response_id = r.id) as answers
from public.survey_responses r
join public.surveys s on s.id = r.survey_id
join auth.users u on u.id = r.user_id
order by r.created_at;
