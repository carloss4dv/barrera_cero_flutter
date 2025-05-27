import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../services/user_service.dart';
import '../../../auth/service/auth_service.dart';
import '../../../../widgets/loading_card.dart';

class BPointsWidget extends StatefulWidget {
  final bool showCompact;
  
  const BPointsWidget({
    Key? key,
    this.showCompact = false,
  }) : super(key: key);

  @override
  State<BPointsWidget> createState() => _BPointsWidgetState();
}

class _BPointsWidgetState extends State<BPointsWidget> {
  final UserService _userService = UserService();
  final AuthService _authService = GetIt.instance<AuthService>();
  int _currentPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final user = await _userService.getUserById(currentUser.uid);
        if (user != null) {
          setState(() {
            _currentPoints = user.contributionPoints;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.showCompact 
        ? const LoadingIndicator(size: 16)
        : const LoadingCard(message: 'Cargando puntos...');
    }

    if (widget.showCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              size: 16,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: 4),            Text(
              '$_currentPoints',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.stars,
              size: 48,
              color: Colors.amber.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              '$_currentPoints B-points',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Puntos de contribución',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que muestra una animación cuando el usuario gana puntos
class BPointsEarnedAnimation extends StatefulWidget {
  final int pointsEarned;
  final VoidCallback? onAnimationComplete;

  const BPointsEarnedAnimation({
    Key? key,
    required this.pointsEarned,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<BPointsEarnedAnimation> createState() => _BPointsEarnedAnimationState();
}

class _BPointsEarnedAnimationState extends State<BPointsEarnedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.pointsEarned} B-points',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
