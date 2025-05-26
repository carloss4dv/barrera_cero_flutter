import 'package:flutter/material.dart';
import '../../domain/models/badge_system.dart';

class BadgesWidget extends StatelessWidget {
  final int bPoints;
  final bool showProgress;
  final bool showCompact;

  const BadgesWidget({
    Key? key,
    required this.bPoints,
    this.showProgress = true,
    this.showCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final earnedBadges = BadgeSystem.getEarnedBadges(bPoints);
    final nextBadge = BadgeSystem.getNextBadge(bPoints);
    final pointsToNext = BadgeSystem.getPointsToNextBadge(bPoints);

    if (showCompact) {
      return _buildCompactView(earnedBadges);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insignias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Insignias ganadas
        if (earnedBadges.isNotEmpty) ...[
          _buildEarnedBadges(earnedBadges),
          const SizedBox(height: 16),
        ],
        
        // Progreso hacia la siguiente insignia
        if (showProgress && nextBadge != null) ...[
          _buildNextBadgeProgress(nextBadge, pointsToNext),
          const SizedBox(height: 16),
        ],
        
        // Todas las insignias disponibles
        _buildAllBadgesGrid(earnedBadges),
      ],
    );
  }

  Widget _buildCompactView(List<BadgeInfo> earnedBadges) {
    if (earnedBadges.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              'Sin insignias',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: earnedBadges.last.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: earnedBadges.last.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            earnedBadges.last.assetPath,
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${earnedBadges.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: earnedBadges.last.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnedBadges(List<BadgeInfo> earnedBadges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insignias obtenidas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: earnedBadges.map((badge) => _buildBadgeCard(badge, isEarned: true)).toList(),
        ),
      ],
    );
  }

  Widget _buildNextBadgeProgress(BadgeInfo nextBadge, int pointsToNext) {
    final progress = (bPoints / nextBadge.requiredPoints).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nextBadge.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: nextBadge.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                nextBadge.assetPath,
                width: 24,
                height: 24,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próxima insignia: ${nextBadge.name}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: nextBadge.color,
                      ),
                    ),
                    Text(
                      'Faltan $pointsToNext B-points',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(nextBadge.color),
          ),
          const SizedBox(height: 4),
          Text(
            '${bPoints}/${nextBadge.requiredPoints} B-points',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBadgesGrid(List<BadgeInfo> earnedBadges) {
    final allBadges = BadgeSystem.getAllBadges();
    final earnedTypes = earnedBadges.map((b) => b.type).toSet();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Todas las insignias',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: allBadges.length,
          itemBuilder: (context, index) {
            final badge = allBadges[index];
            final isEarned = earnedTypes.contains(badge.type);
            return _buildBadgeCard(badge, isEarned: isEarned);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(BadgeInfo badge, {required bool isEarned}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isEarned ? badge.color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned ? badge.color.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            badge.assetPath,
            width: 32,
            height: 32,
            color: isEarned ? null : Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isEarned ? badge.color : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '${badge.requiredPoints} pts',
            style: TextStyle(
              fontSize: 10,
              color: isEarned ? badge.color.withOpacity(0.7) : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isEarned)
            const SizedBox(height: 2),
          if (!isEarned)
            Icon(
              Icons.lock_outline,
              size: 12,
              color: Colors.grey.shade400,
            ),
        ],
      ),
    );
  }
}

/// Widget que muestra una animación cuando se desbloquea una nueva insignia
class BadgeUnlockedAnimation extends StatefulWidget {
  final BadgeInfo badge;
  final VoidCallback? onAnimationComplete;

  const BadgeUnlockedAnimation({
    Key? key,
    required this.badge,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<BadgeUnlockedAnimation> createState() => _BadgeUnlockedAnimationState();
}

class _BadgeUnlockedAnimationState extends State<BadgeUnlockedAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );    _scaleAnimation = Tween<double>(
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
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
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
      builder: (context, child) {        return FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.badge.color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.badge.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    widget.badge.assetPath,
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Nueva insignia desbloqueada!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.badge.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.badge.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
