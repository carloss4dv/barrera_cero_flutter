import 'package:flutter/material.dart';
import '../../domain/challenge_model.dart';
import '../../infrastructure/services/mock_challenge_service.dart';
import 'challenge_card.dart';

class ChallengesPanel extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onClose;

  const ChallengesPanel({
    Key? key,
    required this.isExpanded,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ChallengesPanel> createState() => _ChallengesPanelState();
}

class _ChallengesPanelState extends State<ChallengesPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final MockChallengeService _challengeService = MockChallengeService();
  late List<Challenge> _challenges;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _challenges = _challengeService.getMockChallenges();
  }

  @override
  void didUpdateWidget(ChallengesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final panelHeight = screenHeight * 0.7; // Panel takes 70% of screen height
        
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: _animation.value * panelHeight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(),
                Expanded(
                  child: _buildChallengesList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Desafíos Completados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        return ChallengeCard(challenge: _challenges[index]);
      },
    );
  }
}
