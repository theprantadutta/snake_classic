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

  @override
  String get homePlay => 'ИГРАТЬ';

  @override
  String get homeHighScore => 'РЕКОРД';

  @override
  String homeArmedPowerUp(String name) {
    return 'Заряжено: $name';
  }

  @override
  String homeLoadoutCount(int count) {
    return 'Снаряжение ($count)';
  }

  @override
  String get puSpeedBoost => 'Ускорение';

  @override
  String get puInvincibility => 'Неуязвимость';

  @override
  String get puScoreMultiplier => 'Множитель очков';

  @override
  String get puSlowMotion => 'Замедление';

  @override
  String get homeTilePro => 'PRO';

  @override
  String get homeTileStore => 'МАГАЗИН';

  @override
  String get homeTileFree => 'БОНУС';

  @override
  String get homeTileDaily => 'ЗАДАНИЯ';

  @override
  String get homeTileBattle => 'БИТВА';

  @override
  String get homeTileEvents => 'ТУРНИРЫ';

  @override
  String get homeTileBoard => 'РЕЙТИНГ';

  @override
  String get homeTileFriends => 'ДРУЗЬЯ';

  @override
  String get homeTileCosmetics => 'СТИЛИ';

  @override
  String get homeTileAwards => 'НАГРАДЫ';

  @override
  String get homeTileVersus => 'ДУЭЛЬ';

  @override
  String get homeNoAdReady =>
      'Реклама ещё не готова — попробуйте через несколько секунд.';

  @override
  String get homeFreeSpeedBoostTitle => 'Бесплатное ускорение';

  @override
  String get homeFreeSpeedBoostBody =>
      'Посмотрите короткую рекламу и получите бесплатное ускорение в снаряжение. Оно активируется через 5 секунд после начала следующей игры.';

  @override
  String get homeNotNow => 'Не сейчас';

  @override
  String get homeWatchAd => 'Смотреть рекламу';

  @override
  String get homeFreeSpeedBoostAdded =>
      'Бесплатное ускорение добавлено в снаряжение!';

  @override
  String get homeAdNotFinished =>
      'Реклама не досмотрена — досмотрите до конца, чтобы получить награду.';

  @override
  String get homePickGameMode => 'Выберите режим игры';

  @override
  String get homePickGameModeSubtitle =>
      'Это можно изменить в настройках в любой момент';

  @override
  String get homeStartPlaying => 'НАЧАТЬ ИГРУ';

  @override
  String get homeLoadoutTitle => 'Снаряжение усилений';

  @override
  String get homeLoadoutSubtitle =>
      'Зарядите одно усиление — оно активируется через 5 секунд после начала следующей игры.';

  @override
  String get homeWatchAdFreeSpeedBoost =>
      'Смотреть рекламу — бесплатное ускорение';

  @override
  String get homeNoPowerUps => 'У вас нет усилений.\nЗагляните в магазин!';

  @override
  String homeOwnedCount(int count) {
    return 'В наличии: $count';
  }

  @override
  String get homeArmed => 'ЗАРЯЖЕНО';

  @override
  String get homeDone => 'ГОТОВО';

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get settingsBackToGame => 'ВЕРНУТЬСЯ В ИГРУ';

  @override
  String get settingsSectionControls => 'УПРАВЛЕНИЕ';

  @override
  String get settingsSectionGameplay => 'ГЕЙМПЛЕЙ';

  @override
  String get settingsSectionAudio => 'ЗВУК';

  @override
  String get settingsSectionVisual => 'ВНЕШНИЙ ВИД';

  @override
  String get settingsSectionNotifications => 'УВЕДОМЛЕНИЯ';

  @override
  String get settingsSectionUserProfile => 'ПРОФИЛЬ';

  @override
  String get settingsSectionHelp => 'ПОМОЩЬ И ОБУЧЕНИЕ';

  @override
  String get settingsSectionLegal => 'ПРАВОВАЯ ИНФОРМАЦИЯ';

  @override
  String get settingsSectionPremium => 'ПРЕМИУМ-ФУНКЦИИ';

  @override
  String get settingsDPadControls => 'Экранные кнопки (D-Pad)';

  @override
  String get settingsDPadSubtitle =>
      'Показывать экранные кнопки направления во время игры';

  @override
  String get settingsDPadPosition => 'Положение D-Pad';

  @override
  String get settingsDesktopControls => 'Управление на компьютере';

  @override
  String get settingsArrowKeys => 'Стрелки';

  @override
  String get settingsWasdKeys => 'Клавиши WASD';

  @override
  String get settingsSpacebar => 'Пробел';

  @override
  String get settingsMouseClick => 'Клик мыши';

  @override
  String get settingsChangeDirection => 'Сменить направление';

  @override
  String get settingsPauseResume => 'Пауза/продолжить';

  @override
  String get settingsTouchControlsIfAvailable =>
      'Сенсорное управление (если доступно)';

  @override
  String get settingsTouchControls => 'Сенсорное управление';

  @override
  String get settingsSwipeGestures => 'Свайпы';

  @override
  String get settingsTapScreen => 'Касание экрана';

  @override
  String get settingsSwipeUp => 'Свайп вверх ↑';

  @override
  String get settingsSwipeDown => 'Свайп вниз ↓';

  @override
  String get settingsSwipeLeft => 'Свайп влево ←';

  @override
  String get settingsSwipeRight => 'Свайп вправо →';

  @override
  String get settingsMoveSnakeUp => 'Змейка вверх';

  @override
  String get settingsMoveSnakeDown => 'Змейка вниз';

  @override
  String get settingsMoveSnakeLeft => 'Змейка влево';

  @override
  String get settingsMoveSnakeRight => 'Змейка вправо';

  @override
  String get settingsGameMode => 'Режим игры';

  @override
  String get settingsGameModeLocked =>
      'Завершите текущую игру, чтобы сменить режим';

  @override
  String get settingsDifficulty => 'Сложность';

  @override
  String get settingsDifficultySubtitle =>
      'Задаёт начальную скорость змейки. Каждый режим ускоряется с уровнями.';

  @override
  String get settingsEasyNote =>
      'Монеты, опыт и достижения засчитываются и на лёгком — приостановлены только рекорды и рейтинги.';

  @override
  String get settingsDifficultyLocked =>
      'Завершите текущую игру, чтобы сменить сложность.';

  @override
  String get settingsCurrentSize => 'Текущий размер';

  @override
  String get settingsBoardSizeLocked =>
      'Завершите текущую игру, чтобы сменить размер поля';

  @override
  String get settingsCurrentDuration => 'Текущая длительность';

  @override
  String get settingsCrashFeedbackSubtitle =>
      'Как долго показывать объяснение столкновения';

  @override
  String get settingsScreenShake => 'Тряска экрана';

  @override
  String get settingsScreenShakeSubtitle =>
      'Трясти экран при столкновениях и игровых событиях';

  @override
  String get settingsVibration => 'Вибрация';

  @override
  String get settingsVibrationSubtitle =>
      'Вибрировать при игровых событиях и нажатиях';

  @override
  String get settingsSoundEffects => 'Звуковые эффекты';

  @override
  String get settingsBackgroundMusic => 'Фоновая музыка';

  @override
  String get settingsCurrentTheme => 'Текущая тема';

  @override
  String get settingsBrowseThemes => 'СМОТРЕТЬ ТЕМЫ';

  @override
  String get settingsSnakeTrail => 'Эффекты следа змейки';

  @override
  String get settingsSnakeTrailSubtitle => 'Включить след из частиц за змейкой';

  @override
  String get settingsNotifDailyReminder => 'Ежедневное напоминание';

  @override
  String get settingsNotifTournament => 'Оповещения о турнирах';

  @override
  String get settingsNotifAchievement => 'Новые достижения';

  @override
  String get settingsNotifSocial => 'Социальные обновления';

  @override
  String get settingsNotifSpecialEvents => 'Особые события';

  @override
  String get settingsNotSet => 'Не задано';

  @override
  String get settingsUsername => 'Имя пользователя';

  @override
  String get settingsGuestAccount => 'Гостевой аккаунт';

  @override
  String get settingsAuthenticatedAccount => 'Авторизованный аккаунт';

  @override
  String get settingsChangeUsername => 'СМЕНИТЬ ИМЯ';

  @override
  String get settingsGuestSignInHint =>
      'Войдите, чтобы сохранить прогресс и играть с друзьями';

  @override
  String get settingsUsernameVisibleHint =>
      'Ваше имя видно друзьям и в рейтингах';

  @override
  String get settingsReplayTutorial => 'ПОВТОРИТЬ ОБУЧЕНИЕ';

  @override
  String get settingsReplayTutorialSubtitle =>
      'Посмотреть экскурсию или обучение ещё раз';

  @override
  String get settingsAboutCredits => 'О ПРИЛОЖЕНИИ';

  @override
  String get settingsAboutCreditsSubtitle =>
      'Версия приложения, авторы и ссылки';

  @override
  String get settingsRateApp => 'ОЦЕНИТЬ SNAKE CLASSIC';

  @override
  String get settingsRateAppSubtitleIos =>
      'Нравится игра? Оставьте отзыв в App Store';

  @override
  String get settingsRateAppSubtitle => 'Нравится игра? Оставьте отзыв!';

  @override
  String get settingsAdPrivacy => 'КОНФИДЕНЦИАЛЬНОСТЬ И РЕКЛАМА';

  @override
  String get settingsAdPrivacySubtitle =>
      'Управление согласием на персонализированную рекламу';

  @override
  String get settingsAdPrivacyUnavailable =>
      'Настройки рекламы сейчас недоступны.';

  @override
  String get settingsReplayDialogTitle => 'Повторить обучение';

  @override
  String get settingsReplayDialogBody => 'Какое обучение вы хотите повторить?';

  @override
  String get settingsHomeTour => 'Экскурсия по меню';

  @override
  String get settingsGameTutorial => 'Обучение игре';

  @override
  String get settingsPrivacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get settingsPrivacyPolicyButton => 'ПОЛИТИКА КОНФИДЕНЦИАЛЬНОСТИ';

  @override
  String get settingsTermsTitle => 'Условия использования';

  @override
  String get settingsTermsButton => 'УСЛОВИЯ ИСПОЛЬЗОВАНИЯ';

  @override
  String get settingsChangeUsernameTitle => 'Сменить имя пользователя';

  @override
  String get settingsCurrentLabel => 'Текущее:';

  @override
  String get settingsUsernameDialogBody =>
      'Выберите уникальное имя, которое будет представлять вас в игре.';

  @override
  String get settingsEnterNewUsername => 'Введите новое имя';

  @override
  String get settingsUsernameRules =>
      '• 3-20 символов\n• Должно начинаться с буквы\n• Только буквы, цифры и подчёркивания';

  @override
  String get settingsUsernameUpdateFailed => 'Не удалось обновить имя';

  @override
  String settingsUsernameUpdated(String name) {
    return 'Имя изменено на «$name»';
  }

  @override
  String get settingsUpdate => 'Обновить';

  @override
  String get settingsProTitle => 'Snake Classic Pro';

  @override
  String get settingsPremiumStatus => 'Премиум-статус';

  @override
  String get settingsActiveSubscription => 'Активная подписка';

  @override
  String get settingsUnlockPremium => 'Откройте премиум-функции';

  @override
  String settingsRenews(String date) {
    return 'Продление $date';
  }

  @override
  String get settingsProBadge => 'PRO';

  @override
  String get settingsUpgradeToPro => 'Перейти на Pro';

  @override
  String get settingsRestorePurchases => 'Восстановить покупки';

  @override
  String get settingsPurchaseHistory => 'История покупок';

  @override
  String get settingsSnakeCosmetics => 'Стили змейки';

  @override
  String get settingsBattlePass => 'Боевой пропуск';

  @override
  String settingsTier(int tier) {
    return 'Уровень $tier';
  }

  @override
  String get settingsRestoring => 'Восстановление покупок...';

  @override
  String get settingsRestored => 'Покупки успешно восстановлены!';

  @override
  String get settingsRestoreFailed =>
      'Не удалось восстановить покупки. Попробуйте ещё раз.';

  @override
  String get settingsNoPurchases => 'Покупки не найдены';

  @override
  String get settingsUnknown => 'Неизвестно';

  @override
  String settingsStatusLine(String status) {
    return 'Статус: $status';
  }

  @override
  String settingsDateLine(String date) {
    return 'Дата: $date';
  }

  @override
  String settingsPurchaseNumber(int number) {
    return 'Покупка №$number';
  }

  @override
  String get settingsDataParseError => 'Ошибка чтения данных';

  @override
  String get settingsClose => 'Закрыть';

  @override
  String get settingsHistoryLoadFailed =>
      'Не удалось загрузить историю покупок';

  @override
  String get settingsUnknownDate => 'Дата неизвестна';
}
