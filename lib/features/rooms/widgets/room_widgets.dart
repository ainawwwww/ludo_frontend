import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_constants.dart';
import '../models/room_models.dart';

class RoomBackdrop extends StatelessWidget {
  const RoomBackdrop({super.key, required this.child, required this.type});
  final Widget child;
  final RoomType type;

  @override
  Widget build(BuildContext context) {
    final vip = type == RoomType.vip;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/graphics/bg_home.png', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: vip
                  ? [const Color(0xCC241050), const Color(0xF20B061C)]
                  : [const Color(0xB20B3982), const Color(0xF20C073E)],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class RoomHeader extends StatelessWidget {
  const RoomHeader({
    super.key,
    required this.title,
    required this.type,
    this.subtitle,
    this.onBack,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final RoomType type;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / AppConstants.designWidth;
    final accent = type == RoomType.vip
        ? const Color(0xFFFFD45C)
        : const Color(0xFF5FE8FF);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10 * scale,
          8 * scale,
          10 * scale,
          4 * scale,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 46 * scale,
              child: IconButton(
                onPressed: onBack ?? () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 19 * scale,
                      fontWeight: FontWeight.w900,
                      color: accent,
                      letterSpacing: .5,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10 * scale,
                        fontFamily: 'Poppins',
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 46 * scale, child: trailing),
          ],
        ),
      ),
    );
  }
}

class RoomHeroIcon extends StatelessWidget {
  const RoomHeroIcon({super.key, required this.type, this.size = 96});
  final RoomType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = type == RoomType.vip
        ? 'assets/graphics/vip_room/vip_room_badge.svg'
        : 'assets/graphics/private_room/private_room_key.svg';
    return SvgPicture.asset(asset, width: size, height: size);
  }
}

class RoomGlassCard extends StatelessWidget {
  const RoomGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: .15),
            Colors.white.withValues(alpha: .06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
  }
}

class RoomActionButton extends StatelessWidget {
  const RoomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.type,
    this.enabled = true,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final RoomType type;
  final bool enabled;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = type == RoomType.vip
        ? const [Color(0xFFFFE27A), Color(0xFFFF9D18)]
        : const [Color(0xFF2BD7FF), Color(0xFF3766ED)];
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: .42),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: type == RoomType.vip
                          ? const Color(0xFF4A2800)
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: type == RoomType.vip
                          ? const Color(0xFF4A2800)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoomCodeCard extends StatelessWidget {
  const RoomCodeCard({super.key, required this.code, required this.type});
  final String code;
  final RoomType type;

  @override
  Widget build(BuildContext context) {
    return RoomGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROOM CODE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Room code copied')));
            },
            icon: const Icon(Icons.copy_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class RoomPlayerSeat extends StatelessWidget {
  const RoomPlayerSeat({
    super.key,
    required this.index,
    required this.type,
    this.participant,
    this.onEmptyTap,
  });
  final int index;
  final RoomType type;
  final RoomParticipant? participant;
  final VoidCallback? onEmptyTap;

  @override
  Widget build(BuildContext context) {
    final vip = type == RoomType.vip;
    final accent = vip ? const Color(0xFFFFD45C) : const Color(0xFF55DFFF);
    final p = participant;
    return RoomGlassCard(
      onTap: p == null ? onEmptyTap : null,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  border: Border.all(color: accent, width: 2),
                ),
                child: Icon(
                  p == null
                      ? Icons.person_add_alt_1_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              if (p?.role == RoomRole.host)
                const Positioned(
                  right: -5,
                  top: -6,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFFD45C),
                    size: 22,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            p?.name ?? 'Invite player',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            p == null ? 'Seat $index' : (p.ready ? 'READY' : 'NOT READY'),
            style: TextStyle(
              color: p?.ready == true
                  ? const Color(0xFF70F59A)
                  : Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
