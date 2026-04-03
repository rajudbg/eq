import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:emvo_ui/emvo_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Max characters for a single coach reply (render + memory safety).
const int kCoachMarkdownMaxLength = 28000;

/// Removes NULs, strips inline HTML, and caps length before markdown parse.
String sanitizeCoachMarkdown(String raw) {
  if (raw.isEmpty) return raw;
  final buf = StringBuffer();
  for (final r in raw.runes) {
    if (r != 0) buf.writeCharCode(r);
  }
  var s = buf.toString();
  s = s.replaceAll(RegExp(r'<[^>]{0,800}>', multiLine: true), '');
  if (s.length > kCoachMarkdownMaxLength) {
    s = '${s.substring(0, kCoachMarkdownMaxLength)}\n\n*[Message truncated for safety]*';
  }
  return s.trimRight();
}

bool isAllowedCoachMarkdownLink(String? href) {
  if (href == null || href.trim().isEmpty) return false;
  final t = href.trim();
  final lower = t.toLowerCase();
  if (lower.startsWith('javascript:') ||
      lower.startsWith('data:') ||
      lower.startsWith('vbscript:') ||
      lower.startsWith('file:')) {
    return false;
  }
  final uri = Uri.tryParse(t);
  if (uri == null || !uri.hasScheme) return false;
  return uri.scheme == 'http' ||
      uri.scheme == 'https' ||
      uri.scheme == 'mailto';
}

MarkdownStyleSheet coachMarkdownStyleSheet(
  BuildContext context, {
  required Color foregroundColor,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final baseSize = theme.textTheme.bodyMedium?.fontSize ?? 15;
  final body = theme.textTheme.bodyMedium?.copyWith(
        color: foregroundColor,
        height: 1.52,
        fontSize: baseSize * 1.03,
        letterSpacing: 0.15,
      ) ??
      TextStyle(
        color: foregroundColor,
        height: 1.52,
        fontSize: baseSize * 1.03,
        letterSpacing: 0.15,
      );

  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    p: body,
    pPadding: const EdgeInsets.only(bottom: 8),
    blockSpacing: 12,
    h1: theme.textTheme.titleLarge?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w800,
      height: 1.22,
      letterSpacing: -0.2,
    ),
    h2: theme.textTheme.titleMedium?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w700,
      height: 1.28,
    ),
    h3: theme.textTheme.titleSmall?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    h1Padding: const EdgeInsets.only(top: 6, bottom: 6),
    h2Padding: const EdgeInsets.only(top: 10, bottom: 4),
    h3Padding: const EdgeInsets.only(top: 8, bottom: 2),
    strong: TextStyle(
      fontWeight: FontWeight.w800,
      color: foregroundColor,
      height: 1.45,
    ),
    em: TextStyle(
      fontStyle: FontStyle.italic,
      color: foregroundColor.withValues(alpha: 0.9),
      height: 1.45,
    ),
    del: TextStyle(
      color: foregroundColor.withValues(alpha: 0.55),
      decoration: TextDecoration.lineThrough,
    ),
    a: TextStyle(
      color: EmvoColors.accentCyan,
      decoration: TextDecoration.underline,
      decorationColor: EmvoColors.accentCyan.withValues(alpha: 0.45),
      fontWeight: FontWeight.w600,
      height: 1.45,
    ),
    code: body.copyWith(
      fontFamily: 'monospace',
      fontSize: baseSize * 0.9,
      backgroundColor: Colors.transparent,
      letterSpacing: 0,
    ),
    codeblockDecoration: BoxDecoration(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: EmvoColors.primary.withValues(alpha: 0.28),
        width: 1,
      ),
    ),
    codeblockPadding: const EdgeInsets.all(14),
    blockquoteDecoration: BoxDecoration(
      border: const Border(
        left: BorderSide(
          width: 4,
          color: EmvoColors.primary,
        ),
      ),
      color: EmvoColors.primary.withValues(alpha: 0.07),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
    blockquotePadding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
    blockquote: body.copyWith(
      fontStyle: FontStyle.italic,
      color: foregroundColor.withValues(alpha: 0.88),
    ),
    listBullet: body.copyWith(
      color: EmvoColors.secondary,
      fontWeight: FontWeight.w800,
    ),
    listIndent: 28,
    tableBorder: TableBorder.all(
      color: EmvoColors.primary.withValues(alpha: 0.2),
      width: 1,
      borderRadius: BorderRadius.circular(8),
    ),
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    tableHead: body.copyWith(fontWeight: FontWeight.w700),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: EmvoColors.tertiary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
    ),
  );
}

/// Renders coach replies as sanitized, styled markdown.
class CoachMarkdownView extends StatelessWidget {
  const CoachMarkdownView({
    super.key,
    required this.data,
    required this.textColor,
  });

  final String data;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final sanitized = sanitizeCoachMarkdown(data);

    return MarkdownBody(
      data: sanitized,
      selectable: true,
      styleSheet: coachMarkdownStyleSheet(
        context,
        foregroundColor: textColor,
      ),
      shrinkWrap: true,
      fitContent: true,
      onTapLink: (text, href, title) {
        if (!isAllowedCoachMarkdownLink(href)) return;
        final uri = Uri.parse(href!.trim());
        launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      sizedImageBuilder: (config) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.hide_image_outlined,
                size: 18,
                color: textColor.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Images are not shown in chat for privacy.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.55),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        );
      },
      bulletBuilder: (params) {
        if (params.style == BulletStyle.unorderedList) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: EmvoColors.brandGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: EmvoColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 2, right: 6),
          child: Text(
            '${params.index + 1}.',
            style: const TextStyle(
              color: EmvoColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}
