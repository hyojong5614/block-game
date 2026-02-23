import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bestScoreKey = 'classic_best_score';
const _savedGameStateKey = 'classic_saved_game_state_v1';

void main() {
  runApp(const BlockGameApp());
}

class BlockGameApp extends StatelessWidget {
  const BlockGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Block Game',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DD1A1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StartMenuPage(),
    );
  }
}

class StartMenuPage extends StatelessWidget {
  const StartMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1222),
              Color(0xFF0E1A30),
              Color(0xFF0B1220),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      'Block Game',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: Colors.white.withValues(alpha: 0.96),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '클래식 블록 퍼즐 모드',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ModeCard(
                      title: 'Classic',
                      subtitle: '10x10 보드, 3개 조각, 라인 제거 중심 플레이',
                      accent: const Color(0xFF2EE6B4),
                      icon: Icons.grid_view_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ClassicModePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const _ModeCard(
                      title: 'Adventure',
                      subtitle: '스테이지 기반 모드 (준비 중)',
                      accent: Color(0xFF60A5FA),
                      icon: Icons.map_rounded,
                    ),
                    const SizedBox(height: 12),
                    const _ModeCard(
                      title: 'Time Attack',
                      subtitle: '제한 시간 점수 경쟁 모드 (준비 중)',
                      accent: Color(0xFFF59E0B),
                      icon: Icons.timer_rounded,
                    ),
                    const Spacer(),
                    Text(
                      'Classic을 선택해 게임을 시작하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF111A2C) : const Color(0xFF0F1625),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled
                ? accent.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: enabled ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: enabled ? 0.95 : 0.7),
                        ),
                      ),
                      if (!enabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'SOON',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: enabled ? 0.65 : 0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
              color: Colors.white.withValues(alpha: enabled ? 0.7 : 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassicModePage extends StatefulWidget {
  const ClassicModePage({super.key});

  @override
  State<ClassicModePage> createState() => _ClassicModePageState();
}

class _ClassicModePageState extends State<ClassicModePage> {
  final ClassicGameController _game = ClassicGameController();

  Point<int>? _hoverAnchor;
  int? _draggingTrayIndex;
  Set<String> _recentClearedCells = const {};
  Timer? _clearFlashTimer;
  String? _scoreGainText;
  bool _showScoreGain = false;
  Timer? _scoreGainTimer;

  @override
  void initState() {
    super.initState();
    _game.reset();
    _loadBestScore();
    _loadSavedGame();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _game.bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    });
  }

  Future<void> _saveBestScoreIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bestScoreKey, _game.bestScore);
  }

  Future<void> _loadSavedGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedGameStateKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      if (!_game.restoreFromJson(decoded)) return;
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      // Ignore invalid local save data.
    }
  }

  Future<void> _saveCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedGameStateKey, jsonEncode(_game.toJson()));
  }

  Future<void> _handlePlacement(int x, int y) async {
    final result = _game.tryPlaceSelectedAt(x, y);
    if (!result.placed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('여기에 배치할 수 없습니다.'),
            duration: Duration(milliseconds: 700),
          ),
        );
      }
      return;
    }

    setState(() {
      _hoverAnchor = null;
      _recentClearedCells = result.clearedCells;
      _scoreGainText = result.scoreGained > 0 ? '+${result.scoreGained}' : null;
      _showScoreGain = result.scoreGained > 0;
    });

    if (result.scoreGained > 0) {
      _scoreGainTimer?.cancel();
      _scoreGainTimer = Timer(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        setState(() {
          _showScoreGain = false;
        });
      });
    }

    HapticFeedback.selectionClick();
    if (result.bestScoreUpdated) {
      _saveBestScoreIfNeeded();
    }
    _saveCurrentGame();

    if (result.cleared > 0 && mounted) {
      HapticFeedback.mediumImpact();
      _clearFlashTimer?.cancel();
      _clearFlashTimer = Timer(const Duration(milliseconds: 220), () {
        if (!mounted) return;
        setState(() {
          _recentClearedCells = const {};
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('라인 제거 +${result.cleared}칸'),
          duration: const Duration(milliseconds: 600),
        ),
      );
    }

    if (_game.isGameOver && mounted) {
      HapticFeedback.heavyImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('게임 오버'),
            content: Text('점수: ${_game.score}\n최고 점수: ${_game.bestScore}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _hoverAnchor = null;
                    _draggingTrayIndex = null;
                    _recentClearedCells = const {};
                    _scoreGainText = null;
                    _showScoreGain = false;
                    _game.reset();
                  });
                  _saveCurrentGame();
                },
                child: const Text('다시 시작'),
              ),
            ],
          ),
        );
      });
    }
  }

  void _onBoardTap(int x, int y) {
    if (_game.selectedTrayIndex == null) return;
    _handlePlacement(x, y);
  }

  void _onDragStart(int trayIndex) {
    setState(() {
      _draggingTrayIndex = trayIndex;
      _game.selectedTrayIndex = trayIndex;
    });
  }

  void _onDragEnd() {
    if (!mounted) return;
    setState(() {
      _draggingTrayIndex = null;
      _hoverAnchor = null;
    });
  }

  @override
  void dispose() {
    _clearFlashTimer?.cancel();
    _scoreGainTimer?.cancel();
    super.dispose();
  }

  void _onBoardHover(Point<int>? anchor) {
    if (!mounted) return;
    setState(() {
      _hoverAnchor = anchor;
    });
  }

  void _onBoardDrop(Point<int> anchor) {
    _handlePlacement(anchor.x, anchor.y);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _game.selectedTrayIndex;
    final helperText = _draggingTrayIndex != null
        ? '드래그 중: 보드에 놓아 배치하세요'
        : selected == null
            ? '아래 조각을 드래그해서 보드로 옮기세요'
            : '조각을 드래그해서 보드에 배치하세요';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classic Block Puzzle'),
        actions: [
          IconButton(
            tooltip: 'Restart',
            onPressed: () {
              setState(() {
                _hoverAnchor = null;
                _draggingTrayIndex = null;
                _recentClearedCells = const {};
                _scoreGainText = null;
                _showScoreGain = false;
                _game.reset();
              });
              _saveCurrentGame();
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _ScorePanel(game: _game),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: _BoardWidget(
                            game: _game,
                            hoverAnchor: _hoverAnchor,
                            recentClearedCells: _recentClearedCells,
                            onTapCell: _onBoardTap,
                            onHoverAnchor: _onBoardHover,
                            onDropAnchor: _onBoardDrop,
                          ),
                        ),
                        IgnorePointer(
                          child: AnimatedSlide(
                            offset: _showScoreGain ? Offset.zero : const Offset(0, -0.18),
                            duration: const Duration(milliseconds: 180),
                            child: AnimatedOpacity(
                              opacity: _showScoreGain && _scoreGainText != null ? 1 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF102A22).withValues(alpha: 0.94),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0xFF2EE6B4).withValues(alpha: 0.55),
                                    ),
                                  ),
                                  child: Text(
                                    _scoreGainText ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF6EF2CC),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      helperText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TrayWidget(
                      game: _game,
                      draggingTrayIndex: _draggingTrayIndex,
                      onSelect: (index) => setState(() {
                        _game.toggleTraySelection(index);
                        _hoverAnchor = null;
                      }),
                      onDragStart: _onDragStart,
                      onDragEnd: _onDragEnd,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.game});

  final ClassicGameController game;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: '점수', value: '${game.score}')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: '최고점수', value: '${game.bestScore}')),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: '연속 제거', value: '${game.combo}')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.72))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardWidget extends StatelessWidget {
  const _BoardWidget({
    required this.game,
    required this.hoverAnchor,
    required this.recentClearedCells,
    required this.onTapCell,
    required this.onHoverAnchor,
    required this.onDropAnchor,
  });

  final ClassicGameController game;
  final Point<int>? hoverAnchor;
  final Set<String> recentClearedCells;
  final void Function(int x, int y) onTapCell;
  final void Function(Point<int>? anchor) onHoverAnchor;
  final void Function(Point<int> anchor) onDropAnchor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / ClassicGameController.boardSize;
          final preview = game.previewCellsForHover(hoverAnchor);
          final isValidPreview = hoverAnchor != null &&
              game.canPlaceSelectedAt(hoverAnchor!.x, hoverAnchor!.y);

          Point<int>? pointForGlobalOffset(Offset globalOffset) {
            final box = context.findRenderObject();
            if (box is! RenderBox) return null;
            final local = box.globalToLocal(globalOffset);
            if (local.dx < 0 || local.dy < 0) return null;
            if (local.dx >= constraints.maxWidth || local.dy >= constraints.maxHeight) {
              return null;
            }
            final x = (local.dx / cellSize).floor();
            final y = (local.dy / cellSize).floor();
            if (x < 0 || y < 0 || x >= ClassicGameController.boardSize || y >= ClassicGameController.boardSize) {
              return null;
            }
            return Point<int>(x, y);
          }

          final grid = Column(
            children: List.generate(ClassicGameController.boardSize, (y) {
              return Row(
                children: List.generate(ClassicGameController.boardSize, (x) {
                  final filled = game.board[y][x];
                  final isPreviewCell = preview?.contains('$x,$y') ?? false;
                  final isClearedFlashCell = recentClearedCells.contains('$x,$y');
                  final cellColor = filled ??
                      (isPreviewCell
                          ? (isValidPreview
                              ? Colors.white.withValues(alpha: 0.14)
                              : Colors.redAccent.withValues(alpha: 0.18))
                          : const Color(0xFF1A2438));

                  return GestureDetector(
                    onTap: () => onTapCell(x, y),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 90),
                      width: cellSize,
                      height: cellSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isPreviewCell
                                ? (isValidPreview
                                    ? Colors.white.withValues(alpha: 0.35)
                                    : Colors.redAccent.withValues(alpha: 0.5))
                                : filled != null
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        child: isClearedFlashCell
                            ? Container(
                                margin: const EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE08A).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              );
            }),
          );

          return DragTarget<TrayDragData>(
            onWillAcceptWithDetails: (_) => !game.isGameOver,
            onMove: (details) {
              onHoverAnchor(pointForGlobalOffset(details.offset));
            },
            onLeave: (_) => onHoverAnchor(null),
            onAcceptWithDetails: (details) {
              final point = pointForGlobalOffset(details.offset);
              onHoverAnchor(null);
              if (point != null) {
                onDropAnchor(point);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return grid;
            },
          );
        },
      ),
    );
  }
}

class _TrayWidget extends StatelessWidget {
  const _TrayWidget({
    required this.game,
    required this.draggingTrayIndex,
    required this.onSelect,
    required this.onDragStart,
    required this.onDragEnd,
  });

  final ClassicGameController game;
  final int? draggingTrayIndex;
  final void Function(int index) onSelect;
  final void Function(int index) onDragStart;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final piece = game.tray[index];
        final selected = game.selectedTrayIndex == index;
        final isDragging = draggingTrayIndex == index;

        Widget tile = _TrayPieceTile(
          piece: piece,
          selected: selected,
          dimmed: isDragging,
          onTap: piece == null ? null : () => onSelect(index),
        );

        if (piece != null) {
          tile = Draggable<TrayDragData>(
            data: TrayDragData(index: index, piece: piece),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            onDragStarted: () => onDragStart(index),
            onDragEnd: (_) => onDragEnd(),
            feedback: Material(
              type: MaterialType.transparency,
              child: Transform.scale(
                scale: 1.08,
                child: _FloatingPieceFeedback(piece: piece),
              ),
            ),
            childWhenDragging: _TrayPieceTile(
              piece: piece,
              selected: selected,
              dimmed: true,
              onTap: () => onSelect(index),
            ),
            child: tile,
          );
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
            child: tile,
          ),
        );
      }),
    );
  }
}

class _TrayPieceTile extends StatelessWidget {
  const _TrayPieceTile({
    required this.piece,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final PieceInstance? piece;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pieceValue = piece;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: dimmed ? 0.35 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 112,
          decoration: BoxDecoration(
            color: piece == null
                ? const Color(0xFF111726)
                : selected
                    ? const Color(0xFF1B2A43)
                    : const Color(0xFF121A2B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2EE6B4)
                  : Colors.white.withValues(alpha: 0.08),
              width: selected ? 2 : 1,
            ),
          ),
          child: pieceValue == null
              ? Center(
                  child: Text(
                    '사용됨',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                  ),
                )
              : Center(child: _PiecePreview(piece: pieceValue)),
        ),
      ),
    );
  }
}

class _FloatingPieceFeedback extends StatelessWidget {
  const _FloatingPieceFeedback({required this.piece});

  final PieceInstance piece;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF121A2B).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: _PiecePreview(piece: piece, cellSize: 18),
    );
  }
}

class _PiecePreview extends StatelessWidget {
  const _PiecePreview({required this.piece, this.cellSize = 16});

  final PieceInstance piece;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: piece.shape.width * cellSize + 6,
      height: piece.shape.height * cellSize + 6,
      child: Stack(
        children: piece.shape.cells.map((cell) {
          return Positioned(
            left: cell.x * cellSize,
            top: cell.y * cellSize,
            child: Container(
              width: cellSize - 2,
              height: cellSize - 2,
              decoration: BoxDecoration(
                color: piece.color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TrayDragData {
  const TrayDragData({required this.index, required this.piece});

  final int index;
  final PieceInstance piece;
}

class PlacementResult {
  const PlacementResult({
    required this.placed,
    this.cleared = 0,
    this.bestScoreUpdated = false,
    this.clearedCells = const {},
    this.scoreGained = 0,
  });

  final bool placed;
  final int cleared;
  final bool bestScoreUpdated;
  final Set<String> clearedCells;
  final int scoreGained;
}

class ClassicGameController {
  static const int boardSize = 10;

  final Random _random = Random();

  late List<List<Color?>> board;
  late List<PieceInstance?> tray;
  int? selectedTrayIndex;
  int score = 0;
  int bestScore = 0;
  int combo = 0;
  bool isGameOver = false;

  final List<Color> _pieceColors = const [
    Color(0xFF5EEAD4),
    Color(0xFF60A5FA),
    Color(0xFFF59E0B),
    Color(0xFFF472B6),
    Color(0xFF34D399),
    Color(0xFFA78BFA),
    Color(0xFFF87171),
  ];

  void reset() {
    board = List.generate(boardSize, (_) => List<Color?>.filled(boardSize, null));
    tray = List<PieceInstance?>.filled(3, null);
    selectedTrayIndex = null;
    score = 0;
    combo = 0;
    isGameOver = false;
    _refillTray();
    _recomputeGameOver();
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'bestScore': bestScore,
      'combo': combo,
      'selectedTrayIndex': selectedTrayIndex,
      'board': [
        for (final row in board)
          [for (final cell in row) cell == null ? -1 : _pieceColors.indexOf(cell)]
      ],
      'tray': [
        for (final piece in tray)
          piece == null
              ? null
              : {
                  'shapeIndex': piece.shapeIndex,
                  'colorIndex': piece.colorIndex,
                }
      ],
    };
  }

  bool restoreFromJson(Map<String, dynamic> json) {
    try {
      final rawBoard = json['board'];
      final rawTray = json['tray'];
      if (rawBoard is! List || rawTray is! List) return false;
      if (rawBoard.length != boardSize || rawTray.length != 3) return false;

      final restoredBoard = List.generate(boardSize, (y) {
        final row = rawBoard[y];
        if (row is! List || row.length != boardSize) {
          throw const FormatException('invalid board row');
        }
        return List<Color?>.generate(boardSize, (x) {
          final value = row[x];
          if (value is! int) throw const FormatException('invalid board cell');
          if (value < 0) return null;
          if (value >= _pieceColors.length) throw const FormatException('bad color index');
          return _pieceColors[value];
        });
      });

      final restoredTray = List<PieceInstance?>.generate(3, (i) {
        final item = rawTray[i];
        if (item == null) return null;
        if (item is! Map) throw const FormatException('invalid tray item');
        final shapeIndex = item['shapeIndex'];
        final colorIndex = item['colorIndex'];
        if (shapeIndex is! int || colorIndex is! int) {
          throw const FormatException('invalid piece indexes');
        }
        if (shapeIndex < 0 || shapeIndex >= PieceLibrary.shapes.length) {
          throw const FormatException('bad shape index');
        }
        if (colorIndex < 0 || colorIndex >= _pieceColors.length) {
          throw const FormatException('bad color index');
        }
        return PieceInstance(
          shape: PieceLibrary.shapes[shapeIndex],
          color: _pieceColors[colorIndex],
          shapeIndex: shapeIndex,
          colorIndex: colorIndex,
        );
      });

      board = restoredBoard;
      tray = restoredTray;
      selectedTrayIndex = (json['selectedTrayIndex'] is int) ? json['selectedTrayIndex'] as int : null;
      if (selectedTrayIndex != null &&
          (selectedTrayIndex! < 0 ||
              selectedTrayIndex! >= tray.length ||
              tray[selectedTrayIndex!] == null)) {
        selectedTrayIndex = null;
      }
      score = (json['score'] is int) ? json['score'] as int : 0;
      combo = (json['combo'] is int) ? json['combo'] as int : 0;
      if (json['bestScore'] is int) {
        bestScore = max(bestScore, json['bestScore'] as int);
      }
      _recomputeGameOver();
      return true;
    } catch (_) {
      return false;
    }
  }

  void toggleTraySelection(int index) {
    if (isGameOver || tray[index] == null) return;
    selectedTrayIndex = selectedTrayIndex == index ? null : index;
  }

  bool canPlaceSelectedAt(int anchorX, int anchorY) {
    final piece = _selectedPiece;
    if (piece == null) return false;
    return _canPlace(piece, anchorX, anchorY);
  }

  Set<String>? previewCellsForHover(Point<int>? anchor) {
    final piece = _selectedPiece;
    if (piece == null || anchor == null) return null;
    return piece.shape.cells
        .map((c) => Point<int>(anchor.x + c.x, anchor.y + c.y))
        .where((p) => p.x >= 0 && p.y >= 0 && p.x < boardSize && p.y < boardSize)
        .map((p) => '${p.x},${p.y}')
        .toSet();
  }

  PlacementResult tryPlaceSelectedAt(int anchorX, int anchorY) {
    if (isGameOver) return const PlacementResult(placed: false);
    final selected = selectedTrayIndex;
    final piece = _selectedPiece;
    if (selected == null || piece == null) {
      return const PlacementResult(placed: false);
    }
    if (!_canPlace(piece, anchorX, anchorY)) {
      return const PlacementResult(placed: false);
    }

    final scoreBefore = score;

    for (final c in piece.shape.cells) {
      board[anchorY + c.y][anchorX + c.x] = piece.color;
    }

    final clearResult = _clearCompletedLines();
    final lineClearCells = clearResult.clearedCount;
    final placedCells = piece.shape.cells.length;
    final lineBonus = lineClearCells * 10;
    combo = lineClearCells > 0 ? combo + 1 : 0;
    final comboBonus = lineClearCells > 0 ? combo * 5 : 0;
    score += placedCells + lineBonus + comboBonus;

    final bestScoreUpdated = score > bestScore;
    if (bestScoreUpdated) {
      bestScore = score;
    }

    tray[selected] = null;
    selectedTrayIndex = null;

    if (tray.every((p) => p == null)) {
      _refillTray();
    }

    _recomputeGameOver();
    final scoreGained = score - scoreBefore;
    return PlacementResult(
      placed: true,
      cleared: lineClearCells,
      bestScoreUpdated: bestScoreUpdated,
      clearedCells: clearResult.clearedCells,
      scoreGained: scoreGained,
    );
  }

  PieceInstance? get _selectedPiece {
    final selected = selectedTrayIndex;
    return selected == null ? null : tray[selected];
  }

  bool _canPlace(PieceInstance piece, int anchorX, int anchorY) {
    for (final c in piece.shape.cells) {
      final x = anchorX + c.x;
      final y = anchorY + c.y;
      if (x < 0 || y < 0 || x >= boardSize || y >= boardSize) return false;
      if (board[y][x] != null) return false;
    }
    return true;
  }

  _ClearResult _clearCompletedLines() {
    final fullRows = <int>[];
    final fullCols = <int>[];

    for (var y = 0; y < boardSize; y++) {
      if (board[y].every((cell) => cell != null)) {
        fullRows.add(y);
      }
    }

    for (var x = 0; x < boardSize; x++) {
      var allFilled = true;
      for (var y = 0; y < boardSize; y++) {
        if (board[y][x] == null) {
          allFilled = false;
          break;
        }
      }
      if (allFilled) {
        fullCols.add(x);
      }
    }

    final cleared = <String>{};
    for (final y in fullRows) {
      for (var x = 0; x < boardSize; x++) {
        board[y][x] = null;
        cleared.add('$x,$y');
      }
    }
    for (final x in fullCols) {
      for (var y = 0; y < boardSize; y++) {
        board[y][x] = null;
        cleared.add('$x,$y');
      }
    }

    return _ClearResult(clearedCount: cleared.length, clearedCells: cleared);
  }

  void _refillTray() {
    for (var i = 0; i < tray.length; i++) {
      tray[i] = _randomPiece();
    }
  }

  PieceInstance _randomPiece() {
    final shapeIndex = _random.nextInt(PieceLibrary.shapes.length);
    final colorIndex = _random.nextInt(_pieceColors.length);
    return PieceInstance(
      shape: PieceLibrary.shapes[shapeIndex],
      color: _pieceColors[colorIndex],
      shapeIndex: shapeIndex,
      colorIndex: colorIndex,
    );
  }

  void _recomputeGameOver() {
    for (final piece in tray) {
      if (piece == null) continue;
      for (var y = 0; y < boardSize; y++) {
        for (var x = 0; x < boardSize; x++) {
          if (_canPlace(piece, x, y)) {
            isGameOver = false;
            return;
          }
        }
      }
    }
    isGameOver = true;
  }
}

class _ClearResult {
  const _ClearResult({required this.clearedCount, required this.clearedCells});

  final int clearedCount;
  final Set<String> clearedCells;
}

class PieceCell {
  const PieceCell(this.x, this.y);

  final int x;
  final int y;
}

class PieceShape {
  PieceShape(List<PieceCell> rawCells) : cells = _normalize(rawCells);

  final List<PieceCell> cells;

  int get width => cells.fold<int>(0, (m, c) => max(m, c.x + 1));
  int get height => cells.fold<int>(0, (m, c) => max(m, c.y + 1));

  static List<PieceCell> _normalize(List<PieceCell> cells) {
    final minX = cells.map((c) => c.x).reduce(min);
    final minY = cells.map((c) => c.y).reduce(min);
    return cells.map((c) => PieceCell(c.x - minX, c.y - minY)).toList();
  }
}

class PieceInstance {
  const PieceInstance({
    required this.shape,
    required this.color,
    required this.shapeIndex,
    required this.colorIndex,
  });

  final PieceShape shape;
  final Color color;
  final int shapeIndex;
  final int colorIndex;
}

class PieceLibrary {
  static final List<PieceShape> shapes = [
    PieceShape([const PieceCell(0, 0)]),
    PieceShape([const PieceCell(0, 0), const PieceCell(1, 0)]),
    PieceShape([const PieceCell(0, 0), const PieceCell(1, 0), const PieceCell(2, 0)]),
    PieceShape([const PieceCell(0, 0), const PieceCell(1, 0), const PieceCell(2, 0), const PieceCell(3, 0)]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(3, 0),
      const PieceCell(4, 0),
    ]),
    PieceShape([const PieceCell(0, 0), const PieceCell(0, 1)]),
    PieceShape([const PieceCell(0, 0), const PieceCell(0, 1), const PieceCell(0, 2)]),
    PieceShape([const PieceCell(0, 0), const PieceCell(0, 1), const PieceCell(0, 2), const PieceCell(0, 3)]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(0, 1),
      const PieceCell(0, 2),
      const PieceCell(0, 3),
      const PieceCell(0, 4),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(0, 1),
      const PieceCell(1, 1),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(0, 1),
      const PieceCell(1, 1),
      const PieceCell(2, 1),
      const PieceCell(0, 2),
      const PieceCell(1, 2),
      const PieceCell(2, 2),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(0, 1),
      const PieceCell(0, 2),
      const PieceCell(1, 2),
    ]),
    PieceShape([
      const PieceCell(1, 0),
      const PieceCell(1, 1),
      const PieceCell(1, 2),
      const PieceCell(0, 2),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(0, 1),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(2, 1),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(0, 1),
      const PieceCell(0, 2),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(2, 1),
      const PieceCell(2, 2),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(1, 1),
    ]),
    PieceShape([
      const PieceCell(0, 1),
      const PieceCell(1, 1),
      const PieceCell(2, 1),
      const PieceCell(1, 0),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(1, 1),
      const PieceCell(2, 1),
    ]),
    PieceShape([
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(0, 1),
      const PieceCell(1, 1),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(0, 1),
    ]),
    PieceShape([
      const PieceCell(0, 0),
      const PieceCell(1, 0),
      const PieceCell(2, 0),
      const PieceCell(1, 1),
      const PieceCell(1, 2),
    ]),
  ];
}
