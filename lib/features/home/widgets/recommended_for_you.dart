import 'package:flutter/material.dart';

import '../../../models/recovery_program_model.dart';
import '../../../services/recovery_program_service.dart';

class RecommendedForYou extends StatelessWidget {
  final VoidCallback? onViewAll;
  final void Function(RecoveryProgramModel program)? onProgramTap;

  const RecommendedForYou({
    super.key,
    this.onViewAll,
    this.onProgramTap,
  });

  // ==============================================================
  // SERVICE
  // ==============================================================

  static final RecoveryProgramService _programService =
      RecoveryProgramService();

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // SECTION HEADER
        // ==========================================================

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF111936),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(20),

                  onTap: onViewAll,

                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFF5146D9),
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        SizedBox(width: 2),

                        Icon(
                          Icons.chevron_right_rounded,
                          size: 19,
                          color:
                              Color(0xFF5146D9),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ==========================================================
        // FIREBASE PROGRAMS
        // ==========================================================

        StreamBuilder<List<RecoveryProgramModel>>(
          stream: _programService.streamFeaturedPrograms(
            limit: 10,
          ),

          builder: (
            context,
            snapshot,
          ) {
            // ======================================================
            // LOADING
            // ======================================================

            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _ProgramsLoading();
            }

            // ======================================================
            // ERROR
            // ======================================================

            if (snapshot.hasError) {
              debugPrint(
                'Recommended programs error: '
                '${snapshot.error}',
              );

              return _ProgramsError(
                onRetry: () {},
              );
            }

            final programs =
                snapshot.data ?? [];

            // ======================================================
            // EMPTY STATE
            // ======================================================

            if (programs.isEmpty) {
              return const _ProgramsEmpty();
            }

            // ======================================================
            // PROGRAM LIST
            // ======================================================

            return SizedBox(
              height: 148,

              child: ListView.separated(
                scrollDirection:
                    Axis.horizontal,

                physics:
                    const BouncingScrollPhysics(),

                padding:
                    const EdgeInsets.only(
                  right: 4,
                ),

                itemCount:
                    programs.length,

                separatorBuilder:
                    (_, __) {
                  return const SizedBox(
                    width: 12,
                  );
                },

                itemBuilder:
                    (context, index) {
                  final program =
                      programs[index];

                  return _RecommendationCard(
                    program: program,

                    onTap: () {
                      if (onProgramTap !=
                          null) {
                        onProgramTap!(
                          program,
                        );
                      } else {
                        debugPrint(
                          'Selected recovery program: '
                          '${program.title}',
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// ================================================================
// RECOMMENDATION CARD
// ================================================================

class _RecommendationCard extends StatelessWidget {
  final RecoveryProgramModel program;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.program,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          borderRadius:
              BorderRadius.circular(20),

          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(
                color:
                    const Color(0xFFE7EAF2),
              ),

              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26345C)
                      .withOpacity(.055),

                  blurRadius: 16,

                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),

            child: Row(
              children: [
                // ==================================================
                // PROGRAM IMAGE
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets.all(6),

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(15),

                    child: SizedBox(
                      width: 82,
                      height: 94,

                      child: _ProgramImage(
                        program: program,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      3,
                      8,
                      9,
                      8,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        // CATEGORY

                        Text(
                          program.displayCategory,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 9.5,

                            color:
                                Color(0xFF756BE7),

                            fontWeight:
                                FontWeight.w800,

                            letterSpacing: .6,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // TITLE

                        Text(
                          program.title,

                          maxLines: 2,

                          overflow:
                              TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 13,

                            height: 1.2,

                            color:
                                Color(0xFF121A3A),

                            fontWeight:
                                FontWeight.w800,

                            letterSpacing: -.25,
                          ),
                        ),

                        const SizedBox(height: 7),

                        // PROGRAM COUNT

                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_outlined,

                              size: 13,

                              color:
                                  Color(0xFF6571D0),
                            ),

                            const SizedBox(
                              width: 4,
                            ),

                            Expanded(
                              child: Text(
                                program
                                    .displayProgramCount,

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize: 10.5,

                                  color:
                                      Color(0xFF68708A),

                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // DIFFICULTY

                        if (program
                            .difficultyLevel
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 6,
                          ),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFF1F0FF,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),

                            child: Text(
                              program
                                  .displayDifficulty,

                              maxLines: 1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(
                                fontSize: 8.5,

                                color:
                                    Color(0xFF5146D9),

                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PROGRAM IMAGE
// ================================================================

class _ProgramImage extends StatelessWidget {
  final RecoveryProgramModel program;

  const _ProgramImage({
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    // ==============================================================
    // NETWORK IMAGE
    // ==============================================================

    if (program.hasNetworkImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            program.imageUrl,

            fit: BoxFit.cover,

            loadingBuilder: (
              context,
              child,
              loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }

              return _imagePlaceholder();
            },

            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              // If network image fails,
              // try local asset.

              if (program.hasAssetImage) {
                return _assetImage();
              }

              return _imagePlaceholder();
            },
          ),

          _imageGradient(),
        ],
      );
    }

    // ==============================================================
    // LOCAL ASSET IMAGE
    // ==============================================================

    if (program.hasAssetImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _assetImage(),

          _imageGradient(),
        ],
      );
    }

    // ==============================================================
    // NO IMAGE
    // ==============================================================

    return _imagePlaceholder();
  }

  Widget _assetImage() {
    return Image.asset(
      program.imagePath,

      fit: BoxFit.cover,

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0F3FF),

      child: const Center(
        child: Icon(
          Icons.medical_services_outlined,

          color:
              Color(0xFF6571D0),

          size: 30,
        ),
      ),
    );
  }

  Widget _imageGradient() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,

              end: Alignment.bottomCenter,

              colors: [
                Colors.transparent,

                Colors.black.withOpacity(.15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// LOADING STATE
// ================================================================

class _ProgramsLoading extends StatelessWidget {
  const _ProgramsLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,

      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount: 3,

        separatorBuilder:
            (_, __) =>
                const SizedBox(width: 12),

        itemBuilder:
            (_, __) {
          return Container(
            width: 230,

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(
                color:
                    const Color(0xFFE7EAF2),
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 82,
                  height: 94,

                  margin:
                      const EdgeInsets.all(6),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF0F2F8),

                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(12),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Container(
                          width: 55,
                          height: 9,

                          decoration: BoxDecoration(
                            color:
                                const Color(
                              0xFFF0F2F8,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 9,
                        ),

                        Container(
                          width: double.infinity,
                          height: 13,

                          decoration: BoxDecoration(
                            color:
                                const Color(
                              0xFFF0F2F8,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        Container(
                          width: 80,
                          height: 11,

                          decoration: BoxDecoration(
                            color:
                                const Color(
                              0xFFF0F2F8,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// EMPTY STATE
// ================================================================

class _ProgramsEmpty extends StatelessWidget {
  const _ProgramsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      height: 125,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFE7EAF2),
        ),
      ),

      child: const Row(
        children: [
          Icon(
            Icons.self_improvement_outlined,

            size: 34,

            color:
                Color(0xFF6571D0),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Recovery programs coming soon',
                  style: TextStyle(
                    fontSize: 14,

                    color:
                        Color(0xFF121A3A),

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Personalized programs will appear here.',
                  style: TextStyle(
                    fontSize: 11.5,

                    color:
                        Color(0xFF7B8297),

                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ERROR STATE
// ================================================================

class _ProgramsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProgramsError({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFFFFE2E2),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_outlined,

            color:
                Color(0xFFE26D6D),

            size: 28,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Unable to load recommendations',
              style: TextStyle(
                fontSize: 12.5,

                color:
                    Color(0xFF5B6070),

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          TextButton(
            onPressed: onRetry,

            child: const Text(
              'Retry',
              style: TextStyle(
                color:
                    Color(0xFF5146D9),

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}