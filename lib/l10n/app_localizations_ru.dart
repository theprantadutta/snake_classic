// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Snake Classic';

  @override
  String get settingsSectionLanguage => 'ЯЗЫК';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languageSystemDefaultSubtitle => 'Использовать язык устройства';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get mpVictory => 'ПОБЕДА!';

  @override
  String get mpDraw => 'НИЧЬЯ';

  @override
  String get mpDefeat => 'ПОРАЖЕНИЕ';

  @override
  String get mpYou => 'Вы';

  @override
  String get mpVs => 'VS';

  @override
  String get mpOpponent => 'Соперник';

  @override
  String get mpBackToLobby => 'В лобби';

  @override
  String get mpPlayAgain => 'Сыграть ещё';

  @override
  String get mpTimeUpDraw => 'Время вышло — абсолютное равенство!';

  @override
  String get mpTimeUpYouWon => 'Время вышло — у вас счёт выше.';

  @override
  String get mpTimeUpYouLost => 'Время вышло — у соперника счёт выше.';

  @override
  String get mpMutualCrashDraw => 'Обе змейки разбились — ничья!';

  @override
  String get mpMutualCrashYouWon => 'Обе змейки разбились — решил ваш счёт.';

  @override
  String get mpMutualCrashYouLost =>
      'Обе змейки разбились — решил счёт соперника.';

  @override
  String get mpMatchCancelled => 'Матч был отменён.';

  @override
  String get mpLastSnakeStanding => 'Соперник разбился. Вы — последняя змейка!';

  @override
  String get mpDeathWall => 'Вы врезались в стену.';

  @override
  String get mpDeathSelf => 'Вы врезались в себя.';

  @override
  String get mpDeathOpponent => 'Вы врезались в соперника.';

  @override
  String get mpDeathHeadOn => 'Лобовое столкновение!';

  @override
  String get mpDeathForfeit =>
      'Слишком долгое отключение — техническое поражение.';

  @override
  String get mpBetterLuck => 'Повезёт в следующий раз!';

  @override
  String mpCoinReward(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count монеты',
      many: '+$count монет',
      few: '+$count монеты',
      one: '+$count монета',
    );
    return '$_temp0';
  }

  @override
  String get mpLeaveGameTitle => 'Покинуть игру?';

  @override
  String get mpLeaveGameBody =>
      'Матч продолжается на сервере — выход засчитывается как поражение.';

  @override
  String get mpLeave => 'Выйти';

  @override
  String get mpReconnecting => 'ПЕРЕПОДКЛЮЧЕНИЕ…';

  @override
  String get mpReconnectingBody => 'Матч всё ещё идёт на сервере.';

  @override
  String get mpGetReady => 'ПРИГОТОВЬТЕСЬ';

  @override
  String get mpDroppingIntoArena => 'Отправляем вас на арену…';

  @override
  String get mpWaitingPlayer => 'Ожидание…';

  @override
  String get mpOut => 'ВЫБЫЛ';

  @override
  String get mpLength => 'ДЛИНА';

  @override
  String get mpSwipe => 'Свайп';

  @override
  String get mpReconnectingInline => 'переподключение…';
}
