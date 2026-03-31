import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/team_logo.dart';
import '../providers/schedule_provider.dart';
import '../data/schedule_models.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarView = true;

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final scheduleAsync = ref.watch(scheduleProvider(month));

    return Scaffold(
      appBar: AppHeader(
        title: '경기 일정',
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = null;
              });
              ref.read(selectedMonthProvider.notifier).state = DateTime.now();
            },
            child: const Text(
              '오늘',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 달력/리스트 탭 바
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _ViewTabButton(
                  icon: Icons.calendar_month,
                  label: '달력',
                  isSelected: _isCalendarView,
                  onTap: () => setState(() => _isCalendarView = true),
                ),
                _ViewTabButton(
                  icon: Icons.list,
                  label: '리스트',
                  isSelected: !_isCalendarView,
                  onTap: () => setState(() => _isCalendarView = false),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Expanded(
            child: _isCalendarView
          ? _CalendarView(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              scheduleAsync: scheduleAsync,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                ref.read(selectedMonthProvider.notifier).state = focusedDay;
              },
            )
          : _ListView(
              scheduleAsync: scheduleAsync,
              month: month,
              onMonthChanged: (dt) {
                setState(() => _focusedDay = dt);
                ref.read(selectedMonthProvider.notifier).state = dt;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 달력 뷰 ───
class _CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final AsyncValue<List<MatchSchedule>> scheduleAsync;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;

  const _CalendarView({
    required this.focusedDay,
    required this.selectedDay,
    required this.scheduleAsync,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            calendarFormat: CalendarFormat.month,
            locale: 'ko_KR',
            availableCalendarFormats: const {CalendarFormat.month: '월'},
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: AppColors.textSecondary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12),
              weekendStyle:
                  TextStyle(color: AppColors.accent, fontSize: 12),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              weekendTextStyle:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              outsideTextStyle:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 14),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  const TextStyle(color: Colors.white, fontSize: 14),
            ),
            eventLoader: (day) {
              return scheduleAsync.whenOrNull(
                    data: (schedules) => schedules
                        .where((s) {
                          final dt = s.dateTime;
                          return dt != null && isSameDay(dt, day);
                        })
                        .toList(),
                  ) ??
                  [];
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final schedule = events.first as MatchSchedule;
                Color dotColor = AppColors.textTertiary;
                if (schedule.isWin) dotColor = AppColors.win;
                if (schedule.isLose) dotColor = AppColors.lose;
                if (schedule.isDraw) dotColor = AppColors.draw;
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // 선택한 날짜의 경기 정보
        if (selectedDay != null)
          scheduleAsync.when(
            data: (schedules) {
              final daySchedules = schedules.where((s) {
                final dt = s.dateTime;
                return dt != null && isSameDay(dt, selectedDay!);
              }).toList();

              if (daySchedules.isEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.sports_baseball_outlined,
                          size: 36, color: AppColors.textTertiary.withOpacity(0.4)),
                      const SizedBox(height: 10),
                      const Text(
                        '이 날은 경기가 없습니다',
                        style: TextStyle(
                            color: AppColors.textTertiary, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: daySchedules.map((s) {
                  final resultColor = s.isWin
                      ? AppColors.win
                      : s.isLose
                          ? AppColors.lose
                          : s.isDraw
                              ? AppColors.draw
                              : AppColors.textTertiary;

                  return Container(
                    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                      child: Column(
                        children: [
                          // 팀 vs 팀 스코어
                          Row(
                            children: [
                              // 롯데
                              Expanded(
                                child: Column(
                                  children: [
                                    const TeamLogo(team: '롯데', size: 48),
                                    const SizedBox(height: 6),
                                    const Text(
                                      '롯데',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 스코어 / 시간
                              Column(
                                children: [
                                  if (s.hasScore) ...[
                                    Row(
                                      children: [
                                        Text(
                                          s.awayScore ?? '-',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            ':',
                                            style: TextStyle(
                                              color: AppColors.textTertiary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          s.homeScore ?? '-',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: resultColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        s.result,
                                        style: TextStyle(
                                          color: resultColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      s.time,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        '경기 예정',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // 상대팀
                              Expanded(
                                child: Column(
                                  children: [
                                    TeamLogo(team: s.teamName, size: 48),
                                    const SizedBox(height: 6),
                                    Text(
                                      s.teamName.split(' ').first,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // 경기장, 시간, 날짜 정보
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.divider),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                s.stadium,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 10,
                                color: AppColors.divider,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              const Icon(Icons.access_time,
                                  size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                s.time,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 10,
                                color: AppColors.divider,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              const Icon(Icons.calendar_today,
                                  size: 13, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                s.date,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        const SizedBox(height: 16),
      ],
      ),
    );
  }
}

// ─── 리스트 뷰 ───
class _ListView extends StatelessWidget {
  final AsyncValue<List<MatchSchedule>> scheduleAsync;
  final DateTime month;
  final void Function(DateTime) onMonthChanged;

  const _ListView({
    required this.scheduleAsync,
    required this.month,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 월 선택 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.textSecondary),
                onPressed: () => onMonthChanged(
                    DateTime(month.year, month.month - 1)),
              ),
              Text(
                '${month.year}년 ${month.month}월',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onPressed: () => onMonthChanged(
                    DateTime(month.year, month.month + 1)),
              ),
            ],
          ),
        ),
        // 전적 요약
        scheduleAsync.when(
          data: (schedules) {
            final wins = schedules.where((s) => s.isWin).length;
            final losses = schedules.where((s) => s.isLose).length;
            final draws = schedules.where((s) => s.isDraw).length;
            final total = schedules.length;
            final played = wins + losses + draws;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem('경기', '$total'),
                  _SummaryItem('승', '$wins', color: AppColors.win),
                  _SummaryItem('패', '$losses', color: AppColors.lose),
                  _SummaryItem('무', '$draws', color: AppColors.draw),
                  _SummaryItem(
                    '승률',
                    played > 0
                        ? (wins / played).toStringAsFixed(3)
                        : '-',
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        // 경기 리스트
        Expanded(
          child: scheduleAsync.when(
            data: (schedules) {
              if (schedules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy,
                          size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        '이번 달 경기 일정이 없습니다',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  return _ScheduleCard(schedule: schedules[index]);
                },
              );
            },
            loading: () => const LoadingIndicator(),
            error: (e, _) =>
                const Center(child: Text('일정을 불러올 수 없습니다')),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryItem(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ─── 공통 카드 ───
class _ScheduleCard extends StatelessWidget {
  final MatchSchedule schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: schedule.isWin
            ? Border.all(color: AppColors.win.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  '${schedule.dayNumber}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  schedule.dayOfWeek,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${schedule.teamName}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      schedule.stadium,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      schedule.time,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (schedule.hasScore)
            Column(
              children: [
                Text(
                  schedule.score,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: schedule.isWin
                        ? AppColors.win.withOpacity(0.15)
                        : schedule.isLose
                            ? AppColors.lose.withOpacity(0.15)
                            : AppColors.draw.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    schedule.result,
                    style: TextStyle(
                      color: schedule.isWin
                          ? AppColors.win
                          : schedule.isLose
                              ? AppColors.lose
                              : AppColors.draw,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
