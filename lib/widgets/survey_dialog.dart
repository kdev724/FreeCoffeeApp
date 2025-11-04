import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class SurveyDialog extends StatefulWidget {
  final Function(double) onCreditsEarned;
  final VoidCallback? onDialogClosed;

  const SurveyDialog({
    super.key,
    required this.onCreditsEarned,
    this.onDialogClosed,
  });

  @override
  State<SurveyDialog> createState() => _SurveyDialogState();
}

class _SurveyDialogState extends State<SurveyDialog> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;

  // Sample surveys
  final List<Map<String, dynamic>> _surveys = [
    {
      'id': 'coffee_preferences',
      'title': 'Coffee Preferences Survey',
      'description': 'Help us understand your coffee drinking habits',
      'credits': 5.0,
      'questions': [
        {
          'question': 'How often do you drink coffee?',
          'options': ['Daily', '2-3 times per week', 'Once a week', 'Rarely']
        },
        {
          'question': 'What type of coffee do you prefer?',
          'options': ['Espresso', 'Latte', 'Cappuccino', 'Americano', 'Other']
        },
        {
          'question': 'How do you usually prepare your coffee?',
          'options': [
            'Coffee machine',
            'Instant coffee',
            'French press',
            'Pour-over',
            'Other'
          ]
        }
      ]
    },
    {
      'id': 'coffee_brands',
      'title': 'Coffee Brands Survey',
      'description': 'Tell us about your favorite coffee brands',
      'credits': 3.0,
      'questions': [
        {
          'question': 'Which coffee brand do you prefer?',
          'options': ['Starbucks', 'Dunkin', 'Peets', 'Local brands', 'Other']
        },
        {
          'question': 'What factors influence your coffee choice?',
          'options': [
            'Price',
            'Quality',
            'Convenience',
            'Brand reputation',
            'Taste'
          ]
        }
      ]
    },
    {
      'id': 'coffee_habits',
      'title': 'Coffee Drinking Habits',
      'description': 'Share your coffee consumption patterns',
      'credits': 4.0,
      'questions': [
        {
          'question': 'When do you usually drink coffee?',
          'options': ['Morning', 'Afternoon', 'Evening', 'Throughout the day']
        },
        {
          'question': 'How much do you spend on coffee monthly?',
          'options': ['Under \$20', '\$20-\$50', '\$50-\$100', 'Over \$100']
        },
        {
          'question': 'Do you prefer hot or iced coffee?',
          'options': ['Hot', 'Iced', 'Both equally']
        }
      ]
    }
  ];

  Map<String, dynamic>? _selectedSurvey;
  List<String> _answers = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.brown.shade600,
                    Colors.brown.shade800,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.assignment,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Take Surveys',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 14),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                        Text(
                          'Earn credits by completing surveys',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                            context, 10),
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDialogClosed?.call();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (_selectedSurvey == null) ...[
                      // Survey Selection
                      ..._surveys
                          .map((survey) => _buildSurveyCard(survey))
                          .toList(),
                    ] else if (_currentQuestionIndex <
                        _selectedSurvey!['questions'].length) ...[
                      // Survey Questions
                      _buildQuestionCard(),
                    ] else ...[
                      // Survey Completion
                      _buildCompletionCard(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyCard(Map<String, dynamic> survey) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.brown.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.quiz,
                  color: Colors.brown.shade700,
                  size: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey['title'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 12),
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade700,
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      survey['description'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 10),
                            color: Colors.brown.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                size: 12,
                color: Colors.brown.shade600,
              ),
              const SizedBox(width: 3),
              Text(
                '${_formatCreditsDisplay(survey['credits'])}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 10),
                      fontWeight: FontWeight.w600,
                      color: Colors.brown.shade600,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: 70,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedSurvey = survey;
                      _currentQuestionIndex = 0;
                      _answers = [];
                      _selectedAnswer = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade600,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Start',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context, 10),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final currentQuestion =
        _selectedSurvey!['questions'][_currentQuestionIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        Row(
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_selectedSurvey!['questions'].length}',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            Text(
              '${_formatCreditsDisplay(_selectedSurvey!['credits'])}',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10),
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Question
        Text(
          currentQuestion['question'],
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Options
        ...currentQuestion['options']
            .map((option) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 0),
                  child: RadioListTile<String>(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 12),
                      ),
                    ),
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ))
            .toList(),

        const SizedBox(height: 12),

        // Navigation buttons
        Row(
          children: [
            if (_currentQuestionIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex--;
                      _selectedAnswer = _answers[_currentQuestionIndex];
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 10),
                    ),
                  ),
                ),
              ),
            if (_currentQuestionIndex > 0) const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedAnswer != null
                    ? () {
                        setState(() {
                          if (_currentQuestionIndex < _answers.length) {
                            _answers[_currentQuestionIndex] = _selectedAnswer!;
                          } else {
                            _answers.add(_selectedAnswer!);
                          }

                          if (_currentQuestionIndex <
                              _selectedSurvey!['questions'].length - 1) {
                            _currentQuestionIndex++;
                            _selectedAnswer =
                                _currentQuestionIndex < _answers.length
                                    ? _answers[_currentQuestionIndex]
                                    : null;
                          } else {
                            _currentQuestionIndex =
                                _selectedSurvey!['questions'].length;
                          }
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex <
                          _selectedSurvey!['questions'].length - 1
                      ? 'Next'
                      : 'Complete',
                  style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 10),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Survey Completed!',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Thank you for your responses',
                      style: TextStyle(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 10),
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDialogClosed?.call();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontSize:
                        ResponsiveHelper.getResponsiveFontSize(context, 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Award credits
                  widget.onCreditsEarned(_selectedSurvey!['credits']);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Earned ${_formatCreditsDisplay(_selectedSurvey!['credits'])}!'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  Navigator.of(context).pop();
                  widget.onDialogClosed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Claim ${_formatCreditsDisplay(_selectedSurvey!['credits'])}',
                  style: TextStyle(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 10),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCreditsDisplay(double amount) {
    if (amount < 0.01) {
      // Show as cents for amounts less than 1 cent
      print('Amount123123123123: $amount');
      double cents = (amount * 100).toDouble();
      return '${cents.toStringAsFixed(2)}¢';
    } else {
      // Show as dollars for larger amounts
      return '\$${amount.toStringAsFixed(2)}';
    }
  }
}
