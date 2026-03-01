abstract class AppStrings {
  // Navigation
  static const String navHome = '홈';
  static const String navCalendar = '캘린더';
  static const String navStatistics = '통계';
  static const String navSettings = '설정';

  // Home
  static const String todayHabits = '오늘의 습관';
  static const String completed = '완료';
  static const String writeJournal = '오늘의 일기 쓰기';
  static const String editJournal = '일기 수정하기';
  static const String noHabitsYet = '아직 등록된 습관이 없어요\n새로운 습관을 추가해보세요!';
  static const String noJournalYet = '오늘의 하루를 기록해보세요';

  // Habits
  static const String addHabit = '습관 추가';
  static const String editHabit = '습관 수정';
  static const String deleteHabit = '습관 삭제';
  static const String deleteConfirm = '정말 이 습관을 삭제하시겠어요?';
  static const String habitName = '습관 이름';
  static const String habitNameHint = '예: 물 2L 마시기';
  static const String selectEmoji = '아이콘 선택';
  static const String selectColor = '색상 선택';
  static const String frequency = '반복 주기';
  static const String daily = '매일';
  static const String weekdaysOnly = '주중만';
  static const String custom = '사용자 지정';
  static const String save = '저장';
  static const String cancel = '취소';
  static const String delete = '삭제';
  static const String manageHabits = '습관 관리';

  // Journal
  static const String journalTitle = '일기';
  static const String journalHint = '오늘 하루는 어땠나요?';
  static const String titleHint = '제목 (선택사항)';
  static const String mood = '오늘의 기분';
  static const String autoSaved = '자동 저장됨';

  // Statistics
  static const String thisWeek = '이번 주';
  static const String thisMonth = '이번 달';
  static const String allTime = '전체';
  static const String currentStreak = '현재 연속';
  static const String longestStreak = '최장 연속';
  static const String completionRate = '달성률';
  static const String days = '일';
  static const String noDataYet = '아직 데이터가 없어요';

  // Mood labels
  static const List<String> moodLabels = [
    '매우 나쁨',
    '나쁨',
    '보통',
    '좋음',
    '매우 좋음',
  ];

  // Mood emojis
  static const List<String> moodEmojis = ['😢', '😔', '😐', '😊', '😄'];

  // Weekday labels (Mon-Sun)
  static const List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  // Settings
  static const String exportData = '데이터 내보내기';
  static const String importData = '데이터 가져오기';
  static const String about = '앱 정보';
  static const String version = '버전';
}
