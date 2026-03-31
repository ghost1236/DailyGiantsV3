import 'song_models.dart';

const _teamVideoId = 'UQltcwYid7w';
const _playerVideoId = 'jmpsrWdcIxM';

String _ytUrl(String videoId, int seconds) =>
    'https://www.youtube.com/watch?v=$videoId&t=${seconds}s';

/// 2026 시즌 롯데 자이언츠 팀 응원가 (유튜브 타임스탬프 기반)
List<CheeringSong> getTeamCheeringSongs() {
  return [
    CheeringSong(id: 1001, title: '승리를 외치자', lyrics: '승리를 외치자 부산 롯데 자이언츠', youtubeUrl: _ytUrl(_teamVideoId, 0)),
    CheeringSong(id: 1002, title: '열정과 낭만', lyrics: '거인의 열정과 낭만이 살아 숨 쉬는 이곳에', youtubeUrl: _ytUrl(_teamVideoId, 107)),
    CheeringSong(id: 1003, title: '올웨이즈 롯데', lyrics: '올웨이즈 롯데 자이언츠', youtubeUrl: _ytUrl(_teamVideoId, 244)),
    CheeringSong(id: 1004, title: '소리높여 외쳐보자 (영원하라)', lyrics: '자~ 롯데의 승리위해 소리높여 외쳐보자', youtubeUrl: _ytUrl(_teamVideoId, 365)),
    CheeringSong(id: 1005, title: '오~ 최강롯데', lyrics: '오~ 최강 롯데 자이언츠', youtubeUrl: _ytUrl(_teamVideoId, 490)),
    CheeringSong(id: 1006, title: '화이팅송', lyrics: '롯데! 롯데! 롯데! 화이팅!', youtubeUrl: _ytUrl(_teamVideoId, 599)),
    CheeringSong(id: 1007, title: '투혼 투지', lyrics: '투혼 투지! 롯데 자이언츠!', youtubeUrl: _ytUrl(_teamVideoId, 713)),
    CheeringSong(id: 1008, title: '승전가', lyrics: '부산 롯데 자이언츠 승리하리라', youtubeUrl: _ytUrl(_teamVideoId, 807)),
    CheeringSong(id: 1009, title: '롯데의 승리를 외치자', lyrics: '롯데의 승리를 외치자', youtubeUrl: _ytUrl(_teamVideoId, 894)),
    CheeringSong(id: 1010, title: '오늘도 승리한다', lyrics: '롯데 자이언츠 오늘도 승리한다', youtubeUrl: _ytUrl(_teamVideoId, 981)),
    CheeringSong(id: 1011, title: 'Dream of Ground', lyrics: 'Dream of Ground 롯데 자이언츠', youtubeUrl: _ytUrl(_teamVideoId, 1095)),
    CheeringSong(id: 1012, title: '챔피언 롯데', lyrics: '영원한 그 이름 챔피언 롯데', youtubeUrl: _ytUrl(_teamVideoId, 1224)),
    CheeringSong(id: 1013, title: '힘차게 외치자', lyrics: '힘차게 외치자 부산 롯데', youtubeUrl: _ytUrl(_teamVideoId, 1308)),
    CheeringSong(id: 1014, title: '롯데만을 사랑하리', lyrics: '롯데만을 사랑하리', youtubeUrl: _ytUrl(_teamVideoId, 1413)),
    CheeringSong(id: 1015, title: '자이언츠 러브송', lyrics: '자이언츠 러브송', youtubeUrl: _ytUrl(_teamVideoId, 1570)),
    CheeringSong(id: 1016, title: '부산 갈매기', lyrics: '7회 응원가', youtubeUrl: _ytUrl(_teamVideoId, 1773)),
    CheeringSong(id: 1017, title: '돌아와요 부산항에', lyrics: '돌아와요 부산항에 그리운 내 형제여', youtubeUrl: _ytUrl(_teamVideoId, 1851)),
    CheeringSong(id: 1018, title: '바다새', lyrics: '승리 시 연주되는 응원가', youtubeUrl: _ytUrl(_teamVideoId, 1916)),
    CheeringSong(id: 1019, title: '승리는 누구', lyrics: '승리는 누구 롯데 자이언츠', youtubeUrl: _ytUrl(_teamVideoId, 2025)),
    CheeringSong(id: 1020, title: '영광의 순간', lyrics: '8회 공격 전 응원가', youtubeUrl: _ytUrl(_teamVideoId, 2158)),
    CheeringSong(id: 1021, title: '우리들의 빛나는 이 순간', lyrics: '우리들의 빛나는 이 순간', youtubeUrl: _ytUrl(_teamVideoId, 2290)),
    CheeringSong(id: 1022, title: '승리를 위한 전진', lyrics: '승리를 위한 전진', youtubeUrl: _ytUrl(_teamVideoId, 2415)),
    CheeringSong(id: 1023, title: '영광을 위해 ⭐신규', lyrics: '2026 신규 응원가', youtubeUrl: _ytUrl(_teamVideoId, 2544)),
  ];
}

/// 2026.03ver 롯데 자이언츠 선수 응원가 (순수 응원가, 등장곡 아님)
List<CheeringSong> getPlayerCheeringSongs() {
  return [
    CheeringSong(id: 2001, title: '황성빈', number: '0', lyrics: '타자', youtubeUrl: _ytUrl(_playerVideoId, 0)),
    CheeringSong(id: 2002, title: '신윤후', number: '3', lyrics: '포수', youtubeUrl: _ytUrl(_playerVideoId, 35)),
    CheeringSong(id: 2003, title: '한태양 (1절)', number: '6', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 56)),
    CheeringSong(id: 2004, title: '한태양 (2절)', number: '6', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 94)),
    CheeringSong(id: 2005, title: '장두성', number: '7', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 128)),
    CheeringSong(id: 2006, title: '전준우', number: '8', lyrics: '외야수', youtubeUrl: _ytUrl(_playerVideoId, 157)),
    CheeringSong(id: 2007, title: '조세진', number: '12', lyrics: '투수', youtubeUrl: _ytUrl(_playerVideoId, 191)),
    CheeringSong(id: 2008, title: '전민재', number: '13', lyrics: '외야수', youtubeUrl: _ytUrl(_playerVideoId, 227)),
    CheeringSong(id: 2009, title: '최항', number: '14', lyrics: '외야수', youtubeUrl: _ytUrl(_playerVideoId, 261)),
    CheeringSong(id: 2010, title: '김민성', number: '16', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 301)),
    CheeringSong(id: 2011, title: '한동희', number: '25', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 341)),
    CheeringSong(id: 2012, title: '유강남', number: '27', lyrics: '포수', youtubeUrl: _ytUrl(_playerVideoId, 379)),
    CheeringSong(id: 2013, title: '손성빈', number: '28', lyrics: '외야수', youtubeUrl: _ytUrl(_playerVideoId, 415)),
    CheeringSong(id: 2014, title: '레이예스', number: '29', lyrics: '외야수', youtubeUrl: _ytUrl(_playerVideoId, 452)),
    CheeringSong(id: 2015, title: '이호준', number: '30', lyrics: '투수', youtubeUrl: _ytUrl(_playerVideoId, 498)),
    CheeringSong(id: 2016, title: '손호영', number: '33', lyrics: '투수', youtubeUrl: _ytUrl(_playerVideoId, 538)),
    CheeringSong(id: 2017, title: '정보근', number: '42', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 572)),
    CheeringSong(id: 2018, title: '노진혁', number: '52', lyrics: '내야수', youtubeUrl: _ytUrl(_playerVideoId, 605)),
    CheeringSong(id: 2019, title: '박승욱', number: '53', lyrics: '포수', youtubeUrl: _ytUrl(_playerVideoId, 645)),
    CheeringSong(id: 2020, title: '박찬형', number: '60', lyrics: '투수', youtubeUrl: _ytUrl(_playerVideoId, 679)),
    CheeringSong(id: 2021, title: '윤동희', number: '91', lyrics: '외야수', youtubeUrl: _ytUrl(_playerVideoId, 713)),
  ];
}
