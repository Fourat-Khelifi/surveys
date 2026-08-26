-- ============================================================================
-- Seed content — four more surveys
-- ============================================================================
--
-- Content rather than schema, but kept as a migration on purpose: it is the
-- only way the catalogue is reproducible from a clean database, and the app is
-- unusable without something to answer. Idempotent — each survey is inserted
-- only if a survey with that title does not already exist, so re-running is a
-- no-op and your dashboard edits are never overwritten.
--
-- Between them these cover every question type the app renders, a spread of
-- durations that exercises all five survey-card colours, and rewards from 8 to
-- 45 points.
-- ============================================================================

do $$
declare
  v_survey uuid;
  v_q      uuid;
begin

  -- ── Coffee &amp; Daily Rituals · 3 min · 8 pts ────────────────────────────────
  if not exists (select 1 from public.surveys where title = 'Coffee and Daily Rituals') then
    insert into public.surveys (title, description, duration, reward)
    values (
      'Coffee and Daily Rituals',
      'Three minutes on what you drink, when, and why. The shortest survey we have — a good one to start with.',
      3, 8
    ) returning id into v_survey;

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 0, 'What do you drink first thing in the morning?', null, 'single_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Coffee'), (v_q, 1, 'Tea'), (v_q, 2, 'Water'),
      (v_q, 3, 'Something else'), (v_q, 4, 'Nothing at all');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, min, max, divisions)
    values (v_survey, 1, 'How many caffeinated drinks do you have on a typical day?',
            'Coffee, tea, energy drinks — all count.', 'slider', true, 0, 8, 8);

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 2, 'Where do you usually get it?', 'Pick all that apply.', 'multiple_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Made at home'), (v_q, 1, 'A local café'), (v_q, 2, 'A chain'),
      (v_q, 3, 'The office machine'), (v_q, 4, 'A vending machine');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 3, 'What would your ideal morning drink be?',
            'Optional — be as specific as you like.', 'long', false, 300);
  end if;

  -- ── Remote Work Reality Check · 8 min · 22 pts ────────────────────────────
  if not exists (select 1 from public.surveys where title = 'Remote Work Reality Check') then
    insert into public.surveys (title, description, duration, reward)
    values (
      'Remote Work Reality Check',
      'Where you work, what actually helps, and what you would change. Honest answers are more useful than diplomatic ones.',
      8, 22
    ) returning id into v_survey;

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 0, 'Where do you do most of your work?', null, 'single_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Fully at home'), (v_q, 1, 'Mostly at home, sometimes in'),
      (v_q, 2, 'An even split'), (v_q, 3, 'Mostly in the office'),
      (v_q, 4, 'Fully in the office');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, min, max, divisions)
    values (v_survey, 1, 'How productive do you feel working from home?',
            '0 is not at all, 10 is your best work.', 'slider', true, 0, 10, 10);

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 2, 'What makes working from home harder?', 'Pick all that apply.', 'multiple_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Not enough separation from home life'), (v_q, 1, 'Loneliness'),
      (v_q, 2, 'Too many meetings'), (v_q, 3, 'A poor setup or chair'),
      (v_q, 4, 'Unreliable internet'), (v_q, 5, 'Nothing — I prefer it');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 3, 'How many minutes do you save by not commuting?',
            'On a typical day, both directions.', 'number', true, 4);

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 4, 'If you could set the policy, what would it be?', null, 'single_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Fully remote'), (v_q, 1, 'Two days in'), (v_q, 2, 'Three days in'),
      (v_q, 3, 'Fully in the office'), (v_q, 4, 'Let each team decide');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 5, 'What one change would improve your working week most?',
            'Optional, and the most useful answer in the survey.', 'long', false, 400);
  end if;

  -- ── Money and Everyday Spending · 12 min · 30 pts ─────────────────────────
  if not exists (select 1 from public.surveys where title = 'Money and Everyday Spending') then
    insert into public.surveys (title, description, duration, reward)
    values (
      'Money and Everyday Spending',
      'How you budget, track and think about day-to-day money. Nothing here asks for account details or exact figures.',
      12, 30
    ) returning id into v_survey;

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 0, 'How do you keep track of what you spend?', null, 'single_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'A budgeting app'), (v_q, 1, 'A spreadsheet'),
      (v_q, 2, 'My banking app alone'), (v_q, 3, 'Pen and paper'),
      (v_q, 4, 'I do not track it');

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 1, 'Which do you use to pay day to day?', 'Pick all that apply.', 'multiple_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Debit card'), (v_q, 1, 'Credit card'), (v_q, 2, 'Phone or watch'),
      (v_q, 3, 'Cash'), (v_q, 4, 'Bank transfer');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, min, max, divisions)
    values (v_survey, 2, 'How confident do you feel about your finances?',
            '0 is not at all, 10 is completely.', 'slider', true, 0, 10, 10);

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 3, 'Roughly what share of your income goes to rent or mortgage?',
            'A percentage. An estimate is fine — 30 for a third, say.', 'decimal', true, 5);

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 4, 'What do you cut first when money is tight?', null, 'single_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Eating out'), (v_q, 1, 'Subscriptions'), (v_q, 2, 'Clothes'),
      (v_q, 3, 'Travel and holidays'), (v_q, 4, 'Groceries'), (v_q, 5, 'Nothing yet');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 5, 'What would make managing money easier for you?', null, 'long', false, 400);
  end if;

  -- ── Screen Time and Sleep · 18 min · 45 pts ───────────────────────────────
  if not exists (select 1 from public.surveys where title = 'Screen Time and Sleep') then
    insert into public.surveys (title, description, duration, reward)
    values (
      'Screen Time and Sleep',
      'The longest survey we run, and the best paid. Covers evening habits, devices in the bedroom, and how well you actually sleep.',
      18, 45
    ) returning id into v_survey;

    insert into public.questions (survey_id, order_index, title, description, type, is_required, min, max, divisions)
    values (v_survey, 0, 'How many hours a day do you spend looking at a screen?',
            'Work and leisure together.', 'slider', true, 0, 16, 16);

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 1, 'What is the last thing you do before sleeping?', null, 'single_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Scroll on my phone'), (v_q, 1, 'Watch something'),
      (v_q, 2, 'Read a book'), (v_q, 3, 'Talk to someone'),
      (v_q, 4, 'Straight to sleep');

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 2, 'Which devices are in your bedroom overnight?', 'Pick all that apply.', 'multiple_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'Phone'), (v_q, 1, 'Laptop'), (v_q, 2, 'Tablet'),
      (v_q, 3, 'Television'), (v_q, 4, 'Smart speaker'), (v_q, 5, 'None');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 3, 'How many hours do you sleep on a typical weeknight?',
            'A decimal is fine — 7.5, for instance.', 'decimal', true, 4);

    insert into public.questions (survey_id, order_index, title, description, type, is_required, min, max, divisions)
    values (v_survey, 4, 'How rested do you feel when you wake up?',
            '0 is exhausted, 10 is fully rested.', 'slider', true, 0, 10, 10);

    insert into public.questions (survey_id, order_index, title, description, type, is_required)
    values (v_survey, 5, 'Have you tried any of these to sleep better?', 'Pick all that apply.', 'multiple_choice', true)
    returning id into v_q;
    insert into public.options (question_id, order_index, label) values
      (v_q, 0, 'A screen curfew'), (v_q, 1, 'Night mode or blue-light filters'),
      (v_q, 2, 'Leaving the phone in another room'), (v_q, 3, 'A sleep tracking app'),
      (v_q, 4, 'A consistent bedtime'), (v_q, 5, 'None of these');

    insert into public.questions (survey_id, order_index, title, description, type, is_required, max_length)
    values (v_survey, 6, 'What actually helped, if anything?', null, 'long', false, 400);
  end if;

end;
$$;

-- The trigger from the previous migration keeps surveys.length in step, so
-- nothing here has to set it. This confirms it did.
select s.title, s.duration, s.reward, s.length as questions, s.is_published,
       (select count(*) from public.questions q
         where q.survey_id = s.id
           and q.type in ('single_choice', 'multiple_choice')
           and not exists (select 1 from public.options o where o.question_id = q.id)
       ) as choice_questions_without_options
from public.surveys s
order by s.reward, s.title;
