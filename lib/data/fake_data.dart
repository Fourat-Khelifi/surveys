// import 'package:surveys/core/constants/enums.dart';
// import 'package:surveys/core/models/option.dart';
// import 'package:surveys/core/models/question.dart';
// import 'package:surveys/core/models/survey.dart';

// final List<Survey> surveys = [
//   ─────────────────────────────────────────────
//   Survey 1 – Social Media Behavior
//   ─────────────────────────────────────────────
//   Survey(
//     id: 1,
//     reward: 12,
//     duration: 5,
//     title: "Social Media Behavior",
//     description:
//         "Tell us about your social media habits and how different platforms fit into your daily routine. Your answers help us understand modern digital behavior.",
//     length: 9,
//     questions: [
//       Question(
//         id: "q4",
//         title: "Which platform do you use most?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "Facebook"),
//           Option(id: "o2", label: "Instagram"),
//           Option(id: "o3", label: "TikTok"),
//         ],
//       ),
//       Question(
//         id: "q2",
//         title: "How many hours a day do you spend on social media?",
//         type: QuestionType.decimal,
//         maxLength: 20,
//       ),
//       Question(
//         id: "q1",
//         title: "What is your age?",
//         type: QuestionType.number,
//         maxLength: 20,
//       ),
//       Question(
//         id: "q3",
//         title: "How many hours a day do you spend on social media (briefly)?",
//         type: QuestionType.number,
//         maxLength: 20,
//       ),

//       Question(
//         id: "q5",
//         title: "Which platforms do you use regularly?",
//         type: QuestionType.multiChoice,
//         options: [
//           Option(id: "o1", label: "Facebook"),
//           Option(id: "o2", label: "Instagram"),
//           Option(id: "o3", label: "TikTok"),
//           Option(id: "o4", label: "Twitter"),
//           Option(id: "o5", label: "LinkedIn"),
//           Option(id: "o6", label: "Twitch"),
//         ],
//       ),
//       Question(
//         id: "q6",
//         title: "How would you rate your overall social media experience?",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q7",
//         title: "Are you willing to reduce your social media usage?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "Yes"),
//           Option(id: "o2", label: "No"),
//         ],
//       ),
//       Question(
//         id: "q8",
//         title: "Give us your email address?",
//         type: QuestionType.email,
//       ),
//       Question(
//         id: "q9",
//         title: "Give us your phone number?",
//         type: QuestionType.phone,
//       ),
//     ],
//   ),

//   ─────────────────────────────────────────────
//   Survey 2 – Employee Satisfaction
//   ─────────────────────────────────────────────
//   Survey(
//     id: 2,
//     title: "Employee Satisfaction",
//     description:
//         "Help us understand how satisfied you are with your current work environment, team dynamics, and overall company culture. All responses are anonymous.",
//     length: 6,
//     duration: 10,
//     reward: 25,
//     questions: [
//       Question(
//         id: "q1",
//         title: "What is your current role?",
//         type: QuestionType.shortText,
//         maxLength: 50,
//       ),
//       Question(
//         id: "q2",
//         title: "What department do you work in?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "Engineering"),
//           Option(id: "o2", label: "Marketing"),
//           Option(id: "o3", label: "Sales"),
//           Option(id: "o4", label: "HR"),
//           Option(id: "o5", label: "Finance"),
//         ],
//       ),
//       Question(
//         id: "q3",
//         title: "Which benefits do you value most?",
//         type: QuestionType.multiChoice,
//         options: [
//           Option(id: "o1", label: "Health Insurance"),
//           Option(id: "o2", label: "Remote Work"),
//           Option(id: "o3", label: "Flexible Hours"),
//           Option(id: "o4", label: "Stock Options"),
//           Option(id: "o5", label: "Learning Budget"),
//           Option(id: "o6", label: "Gym Membership"),
//         ],
//       ),
//       Question(
//         id: "q4",
//         title: "How satisfied are you with your work-life balance?",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q5",
//         title: "How satisfied are you with your manager?",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q6",
//         title: "Please share any additional feedback about your experience.",
//         type: QuestionType.longText,
//         maxLength: 300,
//       ),
//     ],
//   ),

//   ─────────────────────────────────────────────
//   Survey 3 – Product Feedback
//   ─────────────────────────────────────────────
//   Survey(
//     id: 3,
//     title: "Product Feedback",
//     description:
//         "We'd love to hear your thoughts on our latest product release. Your feedback directly influences our roadmap and helps us build a better experience for everyone.",
//     length: 6,
//     duration: 15,
//     reward: 25,
//     questions: [
//       Question(
//         id: "q1",
//         title: "How did you hear about our product?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "Social Media"),
//           Option(id: "o2", label: "Friend / Colleague"),
//           Option(id: "o3", label: "Search Engine"),
//           Option(id: "o4", label: "Advertisement"),
//           Option(id: "o5", label: "App Store"),
//         ],
//       ),
//       Question(
//         id: "q2",
//         title: "Which features do you use most often?",
//         type: QuestionType.multiChoice,
//         options: [
//           Option(id: "o1", label: "Dashboard"),
//           Option(id: "o2", label: "Reports"),
//           Option(id: "o3", label: "Notifications"),
//           Option(id: "o4", label: "Integrations"),
//           Option(id: "o5", label: "Settings"),
//           Option(id: "o6", label: "Dark Mode"),
//         ],
//       ),
//       Question(
//         id: "q3",
//         title: "How would you rate the overall product quality?",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q4",
//         title: "How likely are you to recommend us to a friend?",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q5",
//         title: "What is the one feature you wish we had?",
//         type: QuestionType.shortText,
//         maxLength: 80,
//       ),
//       Question(
//         id: "q6",
//         title: "Please describe any bugs or issues you encountered.",
//         type: QuestionType.longText,
//         maxLength: 500,
//       ),
//     ],
//   ),

//   ─────────────────────────────────────────────
//   Survey 4 – Health & Wellness
//   ─────────────────────────────────────────────
//   Survey(
//     id: 4,
//     title: "Health & Wellness",
//     description:
//         "This survey collects insights on personal health habits, physical activity, and mental well-being. Data is used purely for research and is kept fully anonymous.",
//     length: 6,
//     duration: 20,
//     reward: 25,
//     questions: [
//       Question(
//         id: "q1",
//         title: "How many days per week do you exercise?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "0 days"),
//           Option(id: "o2", label: "1–2 days"),
//           Option(id: "o3", label: "3–4 days"),
//           Option(id: "o4", label: "5+ days"),
//         ],
//       ),
//       Question(
//         id: "q2",
//         title: "Which types of exercise do you engage in?",
//         type: QuestionType.multiChoice,
//         options: [
//           Option(id: "o1", label: "Running"),
//           Option(id: "o2", label: "Weightlifting"),
//           Option(id: "o3", label: "Yoga"),
//           Option(id: "o4", label: "Swimming"),
//           Option(id: "o5", label: "Cycling"),
//           Option(id: "o6", label: "Team Sports"),
//         ],
//       ),
//       Question(
//         id: "q3",
//         title: "How many hours of sleep do you get on average?",
//         type: QuestionType.shortText,
//         maxLength: 10,
//       ),
//       Question(
//         id: "q4",
//         title: "Rate your current stress level.",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q5",
//         title: "Rate your overall physical health.",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q6",
//         title: "Describe any health goals you are currently working towards.",
//         type: QuestionType.longText,
//         maxLength: 300,
//       ),
//     ],
//   ),

//   ─────────────────────────────────────────────
//   Survey 5 – E-Commerce Shopping Experience
//   ─────────────────────────────────────────────
//   Survey(
//     id: 5,
//     title: "E-Commerce Shopping Experience",
//     description:
//         "Share your online shopping preferences and experiences to help us improve our store. We want to ensure every purchase is smooth, safe, and satisfying.",
//     length: 6,
//     duration: 5,
//     reward: 25,
//     questions: [
//       Question(
//         id: "q1",
//         title: "How often do you shop online?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "Daily"),
//           Option(id: "o2", label: "Weekly"),
//           Option(id: "o3", label: "Monthly"),
//           Option(id: "o4", label: "Rarely"),
//         ],
//       ),
//       Question(
//         id: "q2",
//         title: "Which categories do you shop for most?",
//         type: QuestionType.multiChoice,
//         options: [
//           Option(id: "o1", label: "Electronics"),
//           Option(id: "o2", label: "Clothing"),
//           Option(id: "o3", label: "Food & Groceries"),
//           Option(id: "o4", label: "Books"),
//           Option(id: "o5", label: "Home & Garden"),
//           Option(id: "o6", label: "Sports & Outdoors"),
//         ],
//       ),
//       Question(
//         id: "q3",
//         title: "What is your preferred payment method?",
//         type: QuestionType.singleChoice,
//         options: [
//           Option(id: "o1", label: "Credit Card"),
//           Option(id: "o2", label: "PayPal"),
//           Option(id: "o3", label: "Crypto"),
//           Option(id: "o4", label: "Cash on Delivery"),
//         ],
//       ),
//       Question(
//         id: "q4",
//         title: "Rate your last checkout experience.",
//         type: QuestionType.slider,
//         min: 0,
//         max: 10,
//         divisions: 10,
//       ),
//       Question(
//         id: "q5",
//         title: "What is your average monthly spend online (in USD)?",
//         type: QuestionType.shortText,
//         maxLength: 20,
//       ),
//       Question(
//         id: "q6",
//         title: "Tell us what would make your shopping experience better.",
//         type: QuestionType.longText,
//         maxLength: 400,
//       ),
//     ],
//   ),
// ];
