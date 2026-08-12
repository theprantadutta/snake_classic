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
  String get mpRewardProcessing => 'Начисление наград…';

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
  String get accountSwitchTitle => 'Войти в существующий аккаунт?';

  @override
  String get accountSwitchBody =>
      'Если с этого аккаунта уже играли в Snake Classic, будет восстановлен его прогресс — именно он останется у вас. Монеты, рекорды и статистика с этого устройства не переносятся.\n\nЧтобы сохранить прогресс этого устройства, используйте аккаунт, с которого вы ещё не играли.';

  @override
  String get accountSwitchConfirm => 'Всё равно войти';

  @override
  String get settingsAuthenticatedAccount => 'Авторизованный аккаунт';

  @override
  String get accountNotBackedUpTitle => 'Нет резервной копии';

  @override
  String get accountNotBackedUpBody =>
      'Этот прогресс привязан к текущей установке. Войдите, чтобы вернуть его после переустановки или на новом телефоне.';

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
  String get legalAutoRenewDisclosureAppStore =>
      'Оплата списывается с вашего аккаунта App Store при подтверждении покупки. Подписка автоматически продлевается по той же цене и на тот же срок, если она не отменена не позднее чем за 24 часа до окончания текущего периода. Управлять подпиской или отменить её можно в любое время в настройках аккаунта после покупки.';

  @override
  String get legalAutoRenewDisclosureGooglePlay =>
      'Оплата списывается с вашего аккаунта Google Play при подтверждении покупки. Подписка автоматически продлевается по той же цене и на тот же срок, если она не отменена не позднее чем за 24 часа до окончания текущего периода. Управлять подпиской или отменить её можно в любое время в настройках подписок Google Play после покупки.';

  @override
  String get legalTermsEulaLink => 'Условия использования (EULA)';

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

  @override
  String get mpLobbyNoFriends =>
      'Пока нет друзей — добавьте их на экране «Друзья»!';

  @override
  String mpLobbyInviteFriendTo(Object code) {
    return 'Пригласите друга в комнату $code';
  }

  @override
  String mpLobbyInviteSent(Object name) {
    return '🎮 Приглашение отправлено $name!';
  }

  @override
  String get mpLobbyInviteFailed =>
      'Не удалось отправить приглашение — попробуйте ещё раз';

  @override
  String get mpLobbyOffline => 'Вы офлайн. Для мультиплеера нужен интернет.';

  @override
  String get mpLobbyDismiss => 'ЗАКРЫТЬ';

  @override
  String get mpLobbyGo => 'СТАРТ!';

  @override
  String get mpLobbyGetReady => 'Приготовьтесь!';

  @override
  String get mpLobbyTitle => 'МУЛЬТИПЛЕЕР';

  @override
  String get mpLobbySubtitle => 'Играйте с друзьями онлайн';

  @override
  String mpLobbyRoomCode(Object code) {
    return 'Комната: $code';
  }

  @override
  String get mpLobbyRoomCodeCopied => 'Код комнаты скопирован!';

  @override
  String get mpLobbyQuickMatch => 'БЫСТРЫЙ МАТЧ';

  @override
  String get mpLobbyQuickMatchSubtitle =>
      'Классика 1 на 1 — соперник найдётся автоматически';

  @override
  String get mpLobbyFinding => 'ПОИСК...';

  @override
  String get mpLobbyFindMatch => 'НАЙТИ МАТЧ';

  @override
  String get mpLobbySeconds => 'сек';

  @override
  String get mpLobbySearching => 'ПОИСК ИГРОКОВ...';

  @override
  String mpLobbyModePlayers(num count, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count игрока',
      many: '$count игроков',
      few: '$count игрока',
      one: '$count игрок',
    );
    return '$mode • $_temp0';
  }

  @override
  String mpLobbyQueuePosition(Object position) {
    return 'Место в очереди: $position';
  }

  @override
  String get mpLobbyCancelUpper => 'ОТМЕНА';

  @override
  String get mpLobbyUnreachableTitle => 'МАТЧМЕЙКИНГ НЕДОСТУПЕН';

  @override
  String get mpLobbyUnreachableBody =>
      'Не удалось связаться с сервером.\nПроверьте подключение и попробуйте снова.';

  @override
  String get mpLobbyGoBack => 'НАЗАД';

  @override
  String get mpLobbyTryAgain => 'ПОВТОРИТЬ';

  @override
  String mpLobbyWinsChip(Object count) {
    return '$count П';
  }

  @override
  String mpLobbyLossesChip(Object count) {
    return '$count Пр';
  }

  @override
  String mpLobbyDrawsChip(Object count) {
    return '$count Н';
  }

  @override
  String get mpLobbyWinsLabel => 'Победы';

  @override
  String get mpLobbyLossesLabel => 'Поражения';

  @override
  String get mpLobbyDrawsLabel => 'Ничьи';

  @override
  String get mpLobbyRatingLabel => 'Рейтинг';

  @override
  String get mpLobbyJoinRoom => 'ВОЙТИ В КОМНАТУ';

  @override
  String get mpLobbyJoinSubtitle => 'Введите код комнаты для входа';

  @override
  String get mpLobbyEnterRoomCode => 'Введите код комнаты';

  @override
  String get mpLobbyCreateRoom => 'СОЗДАТЬ КОМНАТУ';

  @override
  String get mpLobbyCreateSubtitle =>
      'Создайте комнату 1 на 1 и пригласите друга';

  @override
  String mpLobbyPlayersHeader(Object current, Object max) {
    return 'ИГРОКИ ($current/$max)';
  }

  @override
  String get mpLobbyYouBadge => 'ВЫ';

  @override
  String get mpLobbyWaitingForPlayer => 'Ожидание игрока...';

  @override
  String get mpLobbyStartGame => 'НАЧАТЬ ИГРУ';

  @override
  String get mpLobbyWaitingForHost => 'Ожидание запуска хостом...';

  @override
  String get mpLobbyLeave => 'ВЫЙТИ';

  @override
  String get mpLobbyReadyDone => 'ГОТОВ!';

  @override
  String get mpLobbyReady => 'ГОТОВ';

  @override
  String get mpModeClassicDesc => 'Классическая битва змеек';

  @override
  String get mpModeSpeedDesc => 'Скорость растёт со временем';

  @override
  String get mpModeSurvivalDesc => 'Побеждает последняя выжившая змейка';

  @override
  String get mpModePowerUpDesc => 'Усиления повсюду!';

  @override
  String get mpStatusWaiting => 'Ожидает';

  @override
  String get mpStatusReady => 'Готов';

  @override
  String get mpStatusPlaying => 'Играет';

  @override
  String get mpStatusCrashed => 'Разбился';

  @override
  String get mpStatusDisconnected => 'Отключён';

  @override
  String get goNoAdAvailable =>
      'Реклама сейчас недоступна, попробуйте чуть позже';

  @override
  String goCoinsDoubled(Object count) {
    return '🎉 Монеты удвоены — +$count бонусных монет!';
  }

  @override
  String goWatchToDouble(Object count) {
    return 'Посмотрите рекламу и удвойте свои $count монет';
  }

  @override
  String goRewardClaimLine(Object coins, Object xp) {
    return '+$coins монет  •  +$xp XP';
  }

  @override
  String goClaimedTotal(Object count) {
    return 'Получено $count монет за ежедневные задания!';
  }

  @override
  String get goRibbonNewHighScore => 'НОВЫЙ РЕКОРД!';

  @override
  String get goRibbonTournamentSubmitted => 'ТУРНИРНЫЙ СЧЁТ ОТПРАВЛЕН!';

  @override
  String get goRibbonTournamentFailed =>
      'СЧЁТ НЕ ОТПРАВЛЕН — ПРОВЕРЬТЕ СОЕДИНЕНИЕ';

  @override
  String get goRibbonTournamentSubmitting => 'ОТПРАВКА ТУРНИРНОГО СЧЁТА…';

  @override
  String get goVictory => 'ПОБЕДА!';

  @override
  String get goGameOver => 'ИГРА ОКОНЧЕНА';

  @override
  String get goFinalScore => 'ИТОГОВЫЙ СЧЁТ';

  @override
  String get goLevel => 'УРОВЕНЬ';

  @override
  String get goBest => 'РЕКОРД';

  @override
  String get goCoinsEarned => 'Заработано монет';

  @override
  String get goDailyRewardsReady => 'ЕЖЕДНЕВНЫЕ НАГРАДЫ ГОТОВЫ';

  @override
  String goRewardsSummary(Object coins, num count, Object xp) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count награды',
      many: '$count наград',
      few: '$count награды',
      one: '$count награда',
    );
    return '$_temp0  •  +$coins монет  •  +$xp XP';
  }

  @override
  String get goClaimAll => 'ЗАБРАТЬ ВСЁ';

  @override
  String goXpAmount(Object xp) {
    return '$xp XP';
  }

  @override
  String get goClaim => 'Забрать';

  @override
  String get goAchievements => 'ДОСТИЖЕНИЯ';

  @override
  String get goRecentlyUnlocked => 'Недавно открытые';

  @override
  String get goInProgress => 'В процессе';

  @override
  String get goPlayAgain => 'СЫГРАТЬ ЕЩЁ';

  @override
  String get goMenu => 'МЕНЮ';

  @override
  String get storeTitle => 'Магазин Snake';

  @override
  String get storeTabPro => 'Pro';

  @override
  String get storeTabCoins => 'Монеты';

  @override
  String get storeTabThemes => 'Темы';

  @override
  String get storeTabSkins => 'Скины';

  @override
  String get storeTabTrails => 'Следы';

  @override
  String get storeTabPowerUps => 'Усиления';

  @override
  String get storeYourCoins => 'Ваши монеты Snake';

  @override
  String storeBonusMultiplier(Object multiplier) {
    return 'БОНУС ${multiplier}x';
  }

  @override
  String get storeSubscribeBeforePromoEnds =>
      'Оформите подписку, пока не закончился бесплатный Pro';

  @override
  String get storeChooseYourPlan => 'Выберите план';

  @override
  String get storeWhatYouGet => 'Что вы получаете';

  @override
  String get storeProHeroSubtitle =>
      'Все премиум-темы, скины и следы · большие поля · 2× монеты · премиум-усиления · турнирные входы · премиум боевого пропуска';

  @override
  String get storeMonthly => 'Месяц';

  @override
  String get storeYearly => 'Год';

  @override
  String get storePerMonth => '/мес';

  @override
  String get storePerYear => '/год';

  @override
  String get storeSave17 => 'Экономия 17%';

  @override
  String storePlanDisplayName(Object title) {
    return 'план $title';
  }

  @override
  String get storeVerifyingEllipsis => 'Проверка…';

  @override
  String get storeSubscribe => 'Подписаться';

  @override
  String get storeYoureOnFreePro => 'У вас бесплатный Pro!';

  @override
  String get storeYourePro => 'Вы Pro!';

  @override
  String get storeFreePro => 'Бесплатный Pro';

  @override
  String get storeProMonthly => 'Pro на месяц';

  @override
  String get storeKeepPro => 'Сохранить Pro — подписаться';

  @override
  String get storePromoBadge => 'ПРОМО';

  @override
  String get storeEndingSoon => 'Скоро закончится';

  @override
  String storeEndsInDh(Object days, Object hours) {
    return 'Закончится через $daysд $hoursч';
  }

  @override
  String storeEndsInHm(Object hours, Object minutes) {
    return 'Закончится через $hoursч $minutesм';
  }

  @override
  String storeEndsInM(Object minutes) {
    return 'Закончится через $minutesм';
  }

  @override
  String get storeFeatureExtraLife =>
      'Всегда бесплатная доп. жизнь — возрождайтесь в каждой игре, без рекламы и монет';

  @override
  String get storeFeatureNoAds => 'Без рекламы — играйте совсем без объявлений';

  @override
  String get storeFeatureThemes => 'Все 6 премиум-тем';

  @override
  String get storeFeatureSkins => 'Все 11 премиум-скинов';

  @override
  String get storeFeatureTrails => 'Все 11 премиум-следов';

  @override
  String get storeFeatureBoards => 'Премиум-поля (35×35, 40×40, 50×50)';

  @override
  String get storeFeatureCoins => 'Монеты 2×';

  @override
  String get storeFeaturePowerUps => '5× премиум-усилений каждый цикл';

  @override
  String get storeFeatureTournaments =>
      'Бронзовый + серебряный + золотой турнирные входы каждый цикл';

  @override
  String get storeFeatureBattlePass =>
      'Премиум-ветка боевого пропуска каждый сезон';

  @override
  String storeInitiatingPurchase(Object name) {
    return 'Оформляем покупку $name...';
  }

  @override
  String get storeSubNotAvailable => 'Подписка недоступна. Попробуйте позже.';

  @override
  String get storePurchaseFailed => 'Покупка не удалась. Попробуйте ещё раз.';

  @override
  String get storeBuyCoins => 'Купить монеты Snake';

  @override
  String get storeEarnFreeCoins => 'Получайте монеты бесплатно';

  @override
  String get storeEarnPlay => 'Сыграйте игру';

  @override
  String get storeEarnPlayReward => '5 монет за игру';

  @override
  String get storeEarnDaily => 'Ежедневный вход';

  @override
  String get storeEarnDailyReward => '10-50 монет в день';

  @override
  String get storeEarnAchievements => 'Достижения';

  @override
  String get storeEarnAchievementsReward => '25-100 монет';

  @override
  String get storeEarnTournaments => 'Турниры';

  @override
  String get storeEarnTournamentsReward => '100+ монет';

  @override
  String get storePopularBadge => 'ПОПУЛЯРНО';

  @override
  String storeBuyItem(Object name) {
    return 'Купить $name';
  }

  @override
  String storeBuyCoinsBody(Object coins, Object price) {
    return 'Купить $coins за $price?';
  }

  @override
  String storeBuyForPrice(Object price) {
    return 'Купить - $price';
  }

  @override
  String storeInitiatingFor(Object name) {
    return 'Оформляем покупку $name...';
  }

  @override
  String get storeProductNotAvailable => 'Товар недоступен. Попробуйте позже.';

  @override
  String get storeUnlockedWithPro => 'Открыто с Pro';

  @override
  String get storeIncludedWithPro => 'Входит в Snake Classic Pro';

  @override
  String get storeProBannerThemesOwned => 'Все темы здесь ваши по подписке.';

  @override
  String get storeProBannerThemesUpsell =>
      'Оформите Pro и откройте все темы — без отдельных покупок.';

  @override
  String get storeProBannerSkinsOwned => 'Все скины здесь ваши по подписке.';

  @override
  String get storeProBannerSkinsUpsell =>
      'Оформите Pro и откройте все скины — без отдельных покупок.';

  @override
  String get storeProBannerTrailsOwned => 'Все следы здесь ваши по подписке.';

  @override
  String get storeProBannerTrailsUpsell =>
      'Оформите Pro и откройте все следы — без отдельных покупок.';

  @override
  String get storePremiumThemes => 'Премиум-темы';

  @override
  String get storeFreeThemes => 'Бесплатные темы';

  @override
  String get storeFreeThemesSubtitle =>
      'Всегда доступны — вернитесь в любой момент.';

  @override
  String get storeAllThemesBundle => 'Набор всех тем';

  @override
  String get storeAllThemesBundleSubtitle => 'Все 6 премиум-тем · экономия 33%';

  @override
  String get storePillVerifying => 'ПРОВЕРКА';

  @override
  String get storePillOwned => 'КУПЛЕНО';

  @override
  String get storePillFree => 'БЕСПЛАТНО';

  @override
  String get storePillActive => 'АКТИВНА';

  @override
  String get storePillApply => 'ПРИМЕНИТЬ';

  @override
  String get storePillEquipped => 'НАДЕТО';

  @override
  String get storePillEquip => 'НАДЕТЬ';

  @override
  String get storeThemeDescClassic => 'Тот самый первый облик';

  @override
  String get storeThemeDescModern => 'Чисто и минималистично';

  @override
  String get storeThemeDescNeon => 'Сияющие неоновые ночи';

  @override
  String get storeThemeDescRetro => 'Неоновая аркада 80-х';

  @override
  String get storeThemeDescSpace => 'Космическое звёздное поле';

  @override
  String get storeThemeDescOcean => 'Глубоководная синева';

  @override
  String get storeThemeDescCyberpunk => 'Электрический циан и розовый';

  @override
  String get storeThemeDescForest => 'Яркие изумрудные джунгли';

  @override
  String get storeThemeDescDesert => 'Каньон и бирюза кактусов';

  @override
  String get storeThemeDescCrystal => 'Ледяной кристальный синий';

  @override
  String storeUnlockFor(Object name, Object price) {
    return 'Открыть $name за $price?';
  }

  @override
  String storeVerifyingPurchase(Object name) {
    return 'Проверяем покупку $name…';
  }

  @override
  String get storeThemeNotAvailable => 'Тема недоступна. Попробуйте позже.';

  @override
  String get storeItemNotAvailable => 'Предмет недоступен. Попробуйте позже.';

  @override
  String storeEquippedToast(Object name) {
    return '$name — надето';
  }

  @override
  String get storeFreeSpeedBoostInventory =>
      '🎉 Бесплатное ускорение добавлено в инвентарь!';

  @override
  String get storeWatchAdTitle => 'Посмотреть рекламу — бесплатное ускорение';

  @override
  String get storeWatchAdReady => 'Добавляет 1 ускорение в снаряжение';

  @override
  String get storeWatchAdNotReady => 'Реклама сейчас недоступна';

  @override
  String get puSpeedBoostDesc => 'Увеличивает скорость змейки на 7 секунд.';

  @override
  String get puInvincibilityDesc => 'Проходите сквозь стены и себя 6 секунд.';

  @override
  String get puScoreMultiplierDesc => 'Двойные очки в течение 10 секунд.';

  @override
  String get puSlowMotionDesc => 'Замедляет игру для точности (8 секунд).';

  @override
  String get storePowerUpsInfo =>
      'Купите за монеты и зарядите одно через чип снаряжения на главном экране — оно активируется через 5 с после начала следующей игры.';

  @override
  String get storePowerUps => 'Усиления';

  @override
  String get storePowerUpBundles => 'Наборы усилений';

  @override
  String get storeBundlesSubtitle =>
      'Откройте несколько видов усилений со скидкой.';

  @override
  String storeOwnedCountBadge(Object count) {
    return 'x$count';
  }

  @override
  String get storeInsufficientCoins => 'Недостаточно монет!';

  @override
  String storeBuyPowerUpBody(Object cost, Object name) {
    return 'Купить 1 $name за $cost монет?';
  }

  @override
  String storeBuyCostCoins(Object cost) {
    return 'Купить - $cost монет';
  }

  @override
  String get storePurchaseFailedRetry =>
      'Покупка не удалась. Попробуйте ещё раз.';

  @override
  String storeAddedToLoadout(Object name) {
    return '$name добавлено в снаряжение!';
  }

  @override
  String storeCoinsAmount(Object count) {
    return '$count монет';
  }

  @override
  String get storeBuyUpper => 'КУПИТЬ';

  @override
  String get storeNeedCoins => 'НУЖНЫ МОНЕТЫ';

  @override
  String storeBundleUnlocked(Object name) {
    return '$name открыт!';
  }

  @override
  String get modeClassic => 'Классика';

  @override
  String get modeZen => 'Дзен';

  @override
  String get modeSpeedChallenge => 'Скоростной вызов';

  @override
  String get modeMultiFood => 'Мульти-еда';

  @override
  String get modeSurvival => 'Выживание';

  @override
  String get modeTimeAttack => 'На время';

  @override
  String get modePowerUpMadness => 'Безумие усилений';

  @override
  String get modePerfectGame => 'Идеальная игра';

  @override
  String get modeClassicDesc => 'Классическая змейка со стенами';

  @override
  String get modeZenDesc => 'Без стен - змейка проходит сквозь края экрана';

  @override
  String get modeSpeedChallengeDesc =>
      'Скорость растёт стремительно — максимальный вызов';

  @override
  String get modeMultiFoodDesc =>
      'Несколько кусочков еды появляются одновременно';

  @override
  String get modeSurvivalDesc =>
      'Продержитесь как можно дольше с ограниченными жизнями';

  @override
  String get modeTimeAttackDesc =>
      'Наберите максимум очков за ограниченное время';

  @override
  String get modePowerUpMadnessDesc =>
      'Усиления появляются гораздо чаще — окунитесь в хаос';

  @override
  String get modePerfectGameDesc =>
      'Никогда не пересекайте свой след. Один шаг на пройденную клетку — конец игры.';

  @override
  String get diffEasy => 'Лёгкий';

  @override
  String get diffNormal => 'Обычный';

  @override
  String get diffHard => 'Сложный';

  @override
  String get diffEasyDesc =>
      'Змейка медленнее на старте. Очки не попадают в рейтинги.';

  @override
  String get diffNormalDesc => 'Оригинальный темп Snake Classic.';

  @override
  String get diffHardDesc => 'Начинает быстро и только ускоряется.';

  @override
  String get themeClassic => 'Классика';

  @override
  String get themeModern => 'Модерн';

  @override
  String get themeNeon => 'Неон';

  @override
  String get themeRetro => 'Ретро';

  @override
  String get themeSpace => 'Космос';

  @override
  String get themeOcean => 'Океан';

  @override
  String get themeCyberpunk => 'Киберпанк';

  @override
  String get themeForest => 'Лес';

  @override
  String get themeDesert => 'Пустыня';

  @override
  String get themeCrystal => 'Кристалл';

  @override
  String get dpadLeft => 'Слева';

  @override
  String get dpadCenter => 'По центру';

  @override
  String get dpadRight => 'Справа';

  @override
  String get mpModeClassicBattle => 'Классическая битва';

  @override
  String get mpModeSpeedRun => 'Скоростной забег';

  @override
  String get mpModeSurvivalMode => 'Режим выживания';

  @override
  String get mpModePowerUpMadnessName => 'Безумие усилений';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonViewAll => 'Показать все';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get pfTitle => 'Профиль';

  @override
  String get pfSigningOut => 'Выход...';

  @override
  String get pfGuestPlayer => 'Гость';

  @override
  String get pfVerifiedAccount => 'Подтверждённый аккаунт';

  @override
  String get pfStatistics => 'Статистика';

  @override
  String get pfReplays => 'Повторы';

  @override
  String get pfAchievements => 'Достижения';

  @override
  String get pfLoadingStats => 'Загрузка статистики...';

  @override
  String get pfHighScore => 'Рекорд';

  @override
  String get pfGamesPlayed => 'Сыграно игр';

  @override
  String get pfPlayTime => 'Время игры';

  @override
  String get pfAverageScore => 'Средний счёт';

  @override
  String get pfFoodConsumed => 'Съедено еды';

  @override
  String get pfPowerUps => 'Усиления';

  @override
  String get pfUpgradeTitle => 'Перейти на аккаунт Google';

  @override
  String get pfUpgradeSubtitle =>
      'Сохраните прогресс и синхронизируйте между устройствами';

  @override
  String get pfBenefitSync => 'Синхронизация прогресса';

  @override
  String get pfBenefitSyncSub => 'между устройствами';

  @override
  String get pfBenefitLeaderboards => 'Мировые рейтинги';

  @override
  String get pfBenefitLeaderboardsSub => 'соревнуйтесь со всем миром';

  @override
  String get pfBenefitSocial => 'Друзья и общение';

  @override
  String get pfBenefitSocialSub => 'общайтесь с другими';

  @override
  String get pfSignInGoogle => 'Войти через Google';

  @override
  String get pfSignInApple => 'Войти через Apple';

  @override
  String get pfNoReplays => 'Пока нет повторов. Сыграйте пару игр!';

  @override
  String pfReplaysSaved(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count повтора сохранено',
      many: '$count повторов сохранено',
      few: '$count повтора сохранено',
      one: '$count повтор сохранён',
    );
    return '$_temp0';
  }

  @override
  String get pfAccountManagement => 'Управление аккаунтом';

  @override
  String get pfSignOut => 'Выйти';

  @override
  String get pfDeleteAccount => 'Удалить аккаунт';

  @override
  String get pfAppleUpgradeSuccess => 'Аккаунт успешно привязан к Apple! 🎉';

  @override
  String get pfAppleIdInUse =>
      'У этого Apple ID уже есть аккаунт. Выйдите и войдите через Apple.';

  @override
  String get pfUpgradeFailed =>
      'Не удалось обновить аккаунт. Попробуйте ещё раз.';

  @override
  String get pfUpgradeError => 'Произошла ошибка при обновлении аккаунта.';

  @override
  String get pfGoogleUpgradeSuccess => 'Аккаунт успешно привязан к Google! 🎉';

  @override
  String get pfDeleteAccountTitle => 'Удалить аккаунт?';

  @override
  String pfDeleteAccountBody(Object storeName) {
    return 'Это навсегда удалит ваш аккаунт и всё, что с ним связано:\n\n• Рекорды и статистику\n• Монеты и покупки\n• Темы, скины, следы и усиления\n• Прогресс боевого пропуска и заданий\n• Записи в рейтингах и друзей\n\nЭто нельзя отменить. Активные подписки нужно отменить отдельно в настройках $storeName.';
  }

  @override
  String get pfAppStore => 'App Store';

  @override
  String get pfDeviceAppStore => 'магазина приложений устройства';

  @override
  String get pfAccountDeleted => 'Ваш аккаунт навсегда удалён.';

  @override
  String get pfDeleteFailed =>
      'Не удалось удалить аккаунт. Проверьте соединение и попробуйте ещё раз.';

  @override
  String get pfDeleteForever => 'Удалить навсегда';

  @override
  String get pfSignOutBody =>
      'Точно выйти?\n\nВаш прогресс сохранится, если вы вошли через Google.';

  @override
  String get pfSignedOut => 'Вы успешно вышли 👋';

  @override
  String get stLoading => 'Загрузка статистики...';

  @override
  String get stPerformanceOverview => 'Обзор результатов';

  @override
  String get stTotalGames => 'Всего игр';

  @override
  String get stWinStreak => 'Серия побед';

  @override
  String get stGameActivity => 'Игровая активность';

  @override
  String get stLongestGame => 'Самая долгая игра';

  @override
  String get stHighestLevel => 'Максимальный уровень';

  @override
  String get stPerfectGames => 'Идеальные игры';

  @override
  String get stFoodPowerUps => 'Еда и усиления';

  @override
  String get stPowerUpsUsed => 'Использовано усилений';

  @override
  String get stFavoriteFood => 'Любимая еда';

  @override
  String get stFavoritePowerUp => 'Любимое усиление';

  @override
  String get stPerformanceTrends => 'Динамика результатов';

  @override
  String get stOverallTrend => 'Общий тренд';

  @override
  String get stRecentAverage => 'Средний за последнее время';

  @override
  String get stBestRecent => 'Лучший за последнее время';

  @override
  String get stConsistency => 'Стабильность';

  @override
  String get stScores => 'Очки';

  @override
  String get stTrendLine => 'Линия тренда';

  @override
  String get stPlayPatterns => 'Игровые привычки (последние 7 дней)';

  @override
  String get stWeeklyTime => 'Время за неделю';

  @override
  String get stMostActiveDay => 'Самый активный день';

  @override
  String get stDailyActivity => 'Активность по дням';

  @override
  String get stAchievementProgress => 'Прогресс достижений';

  @override
  String get stViewAllAchievements => 'Все достижения →';

  @override
  String get stViewAchievements => 'ДОСТИЖЕНИЯ';

  @override
  String get stReplaysUpper => 'ПОВТОРЫ';

  @override
  String get stResetStatistics => 'СБРОСИТЬ СТАТИСТИКУ';

  @override
  String get stResetTitle => 'Сбросить статистику?';

  @override
  String get stResetBody =>
      'Это навсегда удалит всю вашу игровую статистику. Действие нельзя отменить.';

  @override
  String get stReset => 'Сбросить';

  @override
  String get stNA => 'Н/Д';

  @override
  String get stExcellent => 'Отлично';

  @override
  String get stGood => 'Хорошо';

  @override
  String get stFair => 'Средне';

  @override
  String get stPoor => 'Слабо';

  @override
  String get stNoData => 'Нет данных';

  @override
  String get stNone => 'Нет';

  @override
  String stProgressLastGames(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count игры',
      many: '$count игр',
      few: '$count игры',
      one: '$count игра',
    );
    return 'Прогресс (последние $_temp0)';
  }

  @override
  String stPercentComplete(Object percent) {
    return '$percent завершено';
  }

  @override
  String get stInsights => 'Анализ результатов';

  @override
  String get stInsightPlayMore =>
      'Сыграйте больше игр, чтобы получить анализ результатов!';

  @override
  String get stInsightImproving => 'Отлично! Ваши результаты растут.';

  @override
  String get stInsightAboveAverage =>
      'Ваши последние игры заметно выше вашего среднего.';

  @override
  String get stInsightDeclined =>
      'Результаты в последнее время снизились. Стоит потренироваться.';

  @override
  String get stInsightPractice =>
      'Сосредоточьтесь на избегании столкновений и планировании ходов.';

  @override
  String get stInsightStable =>
      'Ваши результаты стабильны. Бросьте себе вызов!';

  @override
  String get stInsightPotential =>
      'У вас есть потенциал для рекордов - поработайте над стабильностью.';

  @override
  String get stInsightSolid =>
      'Вы стабильно показываете хорошие результаты в последних играх.';

  @override
  String get frTitle => 'Друзья';

  @override
  String get frBlockedUsers => 'Заблокированные';

  @override
  String get frSearchHint => 'Поиск по имени или почте...';

  @override
  String get frSearching => 'Поиск...';

  @override
  String get frSearchTitle => 'Найти друзей';

  @override
  String get frSearchSubtitle => 'Введите имя или почту, чтобы найти друзей';

  @override
  String get frNoUsersFound => 'Никого не нашли';

  @override
  String get frNoUsersFoundSub => 'Попробуйте другое имя или почту';

  @override
  String get frRequests => 'Заявки';

  @override
  String get frSearch => 'Поиск';

  @override
  String get frNoCacheYet => 'Кэша ещё нет';

  @override
  String frUpdatedAgo(Object ago) {
    return 'Обновлено $ago';
  }

  @override
  String frRefreshFailed(Object base) {
    return '$base · не обновилось, нажмите для повтора';
  }

  @override
  String get frJustNow => 'только что';

  @override
  String frSecondsAgo(Object count) {
    return '$count с назад';
  }

  @override
  String frMinutesAgo(Object count) {
    return '$count мин назад';
  }

  @override
  String frHoursAgo(Object count) {
    return '$count ч назад';
  }

  @override
  String frDaysAgo(Object count) {
    return '$count д назад';
  }

  @override
  String get frLoadingFriends => 'Загрузка друзей...';

  @override
  String get frNoFriendsYet => 'Пока нет друзей';

  @override
  String get frNoFriendsSub => 'Найдите игроков и добавьте их в друзья!';

  @override
  String get frNoRequests => 'Нет заявок в друзья';

  @override
  String get frNoRequestsSub => 'Заявки в друзья появятся здесь';

  @override
  String get frChallengeMenu => 'Вызвать на матч';

  @override
  String get frViewProfile => 'Открыть профиль';

  @override
  String get frRemoveFriend => 'Удалить из друзей';

  @override
  String get frBlockUser => 'Заблокировать';

  @override
  String frReceivedHeader(Object count) {
    return 'Входящие ($count)';
  }

  @override
  String frSentHeader(Object count) {
    return 'Отправленные ($count)';
  }

  @override
  String frGamesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count игры',
      many: '$count игр',
      few: '$count игры',
      one: '$count игра',
    );
    return '$_temp0';
  }

  @override
  String frSentDate(Object date) {
    return 'Отправлено $date';
  }

  @override
  String get frPending => 'Ожидает';

  @override
  String get frCancelRequest => 'Отменить заявку';

  @override
  String get frReject => 'Отклонить';

  @override
  String get frAccept => 'Принять';

  @override
  String get frAlreadyFriends => '✓ Друзья';

  @override
  String get frAddFriend => 'Добавить';

  @override
  String get frSendRequestFailed =>
      'Не удалось отправить заявку — проверьте соединение и попробуйте ещё раз';

  @override
  String get frAcceptFailed =>
      'Не удалось принять заявку — проверьте соединение и попробуйте ещё раз';

  @override
  String get frRejectFailed =>
      'Не удалось отклонить заявку — проверьте соединение и попробуйте ещё раз';

  @override
  String get frCancelFailed =>
      'Не удалось отменить заявку — проверьте соединение и попробуйте ещё раз';

  @override
  String get frBlockFailed =>
      'Не удалось заблокировать — проверьте соединение и попробуйте ещё раз';

  @override
  String get frSignInSocial =>
      'Войдите, чтобы добавлять друзей и пользоваться социальными функциями';

  @override
  String get frRequestSent => 'Заявка в друзья отправлена!';

  @override
  String get frRequestAccepted => 'Заявка в друзья принята!';

  @override
  String get frRequestRejected => 'Заявка в друзья отклонена';

  @override
  String get frRequestCancelled => 'Заявка в друзья отменена';

  @override
  String frChallengeSent(Object name) {
    return '🎮 Вызов отправлен $name!';
  }

  @override
  String get frChallengeFailed =>
      'Не удалось отправить вызов — попробуйте ещё раз';

  @override
  String frBlocked(Object name) {
    return '$name заблокирован';
  }

  @override
  String frUnblocked(Object name) {
    return '$name разблокирован';
  }

  @override
  String get frUnblockFailed =>
      'Не удалось разблокировать — попробуйте ещё раз';

  @override
  String frRemoved(Object name) {
    return '$name удалён из друзей';
  }

  @override
  String frBlockTitle(Object name) {
    return 'Заблокировать $name?';
  }

  @override
  String get frBlockBody =>
      'Игрок будет удалён из ваших друзей и не сможет отправлять вам заявки и вызовы. Уведомления об этом он не получит.';

  @override
  String get frBlock => 'Заблокировать';

  @override
  String get frNoBlocked => 'Вы никого не заблокировали.';

  @override
  String get frUnblock => 'Разблокировать';

  @override
  String frHighScoreLine(Object score) {
    return 'Рекорд: $score';
  }

  @override
  String frTotalGamesLine(Object count) {
    return 'Всего игр: $count';
  }

  @override
  String frLevelLine(Object level) {
    return 'Уровень: $level';
  }

  @override
  String frStatusLine(Object status) {
    return 'Статус: «$status»';
  }

  @override
  String frRemoveBody(Object name) {
    return 'Удалить $name из списка друзей?';
  }

  @override
  String get frRemove => 'Удалить';

  @override
  String get frLeaderboardTitle => 'Рейтинг друзей';

  @override
  String get frLeaderboardSubtitle => 'Соревнуйтесь с друзьями';

  @override
  String get frLoadingLeaderboard => 'Загрузка рейтинга...';

  @override
  String frRankBadge(Object rank) {
    return '№$rank';
  }

  @override
  String get frYou => 'ВЫ';

  @override
  String get frLeaderboardEmptySub =>
      'Добавьте друзей, чтобы увидеть свой личный рейтинг!';

  @override
  String get frAddFriends => 'Добавить друзей';

  @override
  String get tnTitle => 'Турниры';

  @override
  String get tnActive => 'Активные';

  @override
  String get tnHistory => 'История';

  @override
  String get tnMyStats => 'Моя статистика';

  @override
  String get tnLoading => 'Загрузка турниров...';

  @override
  String get tnNoActive => 'Нет активных турниров';

  @override
  String get tnNoActiveSub => 'Загляните позже за новыми турнирами!';

  @override
  String get tnNoHistory => 'Нет истории турниров';

  @override
  String get tnNoHistorySub => 'Участвуйте в турнирах, чтобы увидеть историю!';

  @override
  String get tnNoStats => 'Нет турнирной статистики';

  @override
  String get tnNoStatsSub =>
      'Участвуйте в турнирах, чтобы отслеживать прогресс!';

  @override
  String tnPlayersCount(Object current, Object max) {
    return '$current/$max игроков';
  }

  @override
  String get tnJoined => 'Вы участвуете';

  @override
  String tnBestScoreChip(Object score) {
    return 'Лучший: $score';
  }

  @override
  String tnRankReward(Object rank, Object reward) {
    return 'Место №$rank - $reward';
  }

  @override
  String tnRewardsAvailable(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'доступно $count награды',
      many: 'доступно $count наград',
      few: 'доступно $count награды',
      one: 'доступна $count награда',
    );
    return '$_temp0';
  }

  @override
  String get tnViewDetails => 'Подробнее →';

  @override
  String get tnOverviewCard => 'Обзор турниров';

  @override
  String get tnWins => 'Победы';

  @override
  String get tnTopThree => 'Топ-3 финиша';

  @override
  String get tnBestScore => 'Лучший счёт';

  @override
  String get tnDetailedStats => 'Подробная статистика';

  @override
  String get tnTotalAttempts => 'Всего попыток';

  @override
  String get tnWinRate => 'Процент побед';

  @override
  String tnPercentValue(Object value) {
    return '$value%';
  }

  @override
  String get tnAvgPerformance => 'Средний результат';

  @override
  String tnTopPercent(Object percent) {
    return 'Топ $percent%';
  }

  @override
  String get tnNotFound => 'Турнир не найден';

  @override
  String get tnLoadFailed => 'Не удалось загрузить турнир';

  @override
  String get tnLoadingTournament => 'Загрузка турнира...';

  @override
  String get tnGoBack => 'Назад';

  @override
  String get tnParticipating => 'Вы участвуете!';

  @override
  String tnBestAttempts(Object count, Object score) {
    return 'Лучший: $score • Попытки: $count';
  }

  @override
  String tnRankChip(Object rank) {
    return 'Место №$rank';
  }

  @override
  String get tnOverview => 'Обзор';

  @override
  String get tnLeaderboard => 'Рейтинг';

  @override
  String get tnRules => 'Правила';

  @override
  String get tnLeaderboardFailed => 'Не удалось загрузить рейтинг';

  @override
  String get tnCheckConnection => 'Проверьте соединение и попробуйте ещё раз.';

  @override
  String get tnNoParticipants => 'Пока нет участников';

  @override
  String get tnBeFirst => 'Станьте первым участником!';

  @override
  String get tnDescription => 'Описание';

  @override
  String get tnRewards => 'Награды';

  @override
  String tnAttemptsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count попытки',
      many: '$count попыток',
      few: '$count попытки',
      one: '$count попытка',
    );
    return '$_temp0';
  }

  @override
  String get tnRulesHeader => 'Правила турнира';

  @override
  String get tnScoringSystem => 'Система очков';

  @override
  String get tnScoringBody =>
      'В итоговый рейтинг идёт ваш лучший счёт за время турнира. Можно играть сколько угодно раз, улучшая результат.';

  @override
  String get tnJoining => 'ВСТУПЛЕНИЕ…';

  @override
  String get tnJoin => 'ВСТУПИТЬ В ТУРНИР';

  @override
  String get tnPlayNow => 'ИГРАТЬ';

  @override
  String get tnProUnlimited => 'Pro · Безлимитные входы';

  @override
  String tnEntriesRemaining(Object count) {
    return 'Осталось входов: $count';
  }

  @override
  String get tnNoEntries => 'Нет входов — нажмите ВСТУПИТЬ, чтобы купить';

  @override
  String tnStarts(Object time) {
    return 'Начало $time';
  }

  @override
  String get tnRule1 => 'Играйте во время турнира, чтобы счёт засчитывался';

  @override
  String get tnRule2 =>
      'Можно играть много раз - учитывается только лучший счёт';

  @override
  String get tnRule3 => 'Для участия нужно войти в аккаунт';

  @override
  String get tnRule4 => 'Итоговые места определяются по окончании турнира';

  @override
  String get tnRuleSpeed => 'Скорость игры быстро растёт каждые 10 очков';

  @override
  String get tnRuleSurvival => 'Счёт зависит от времени выживания, а не еды';

  @override
  String get tnRuleNoWalls =>
      'Змейка проходит сквозь края экрана вместо столкновения со стенами';

  @override
  String get tnRulePowerUps => 'Усиления появляются каждые 5 секунд';

  @override
  String get tnRulePerfect => 'Любое столкновение сразу заканчивает игру';

  @override
  String get tnRuleClassic => 'Действуют стандартные правила змейки';

  @override
  String get tnJoinSuccess => 'Вы вступили в турнир!';

  @override
  String get tnJoinFailed => 'Не удалось вступить в турнир';

  @override
  String get tnJoinError => 'Ошибка при вступлении в турнир';

  @override
  String get tnTierBronze => 'Бронзовый';

  @override
  String get tnTierSilver => 'Серебряный';

  @override
  String get tnTierGold => 'Золотой';

  @override
  String get tnEntryRequired => 'Нужен вход';

  @override
  String tnEntryNeeded(Object tier) {
    return 'Для участия в этом турнире нужен $tier вход.';
  }

  @override
  String tnCurrentEntries(Object count, Object tier) {
    return 'Ваши $tier входы: $count';
  }

  @override
  String get tnProUnlimitedNote =>
      'Подписчики Pro получают безлимитный доступ к турнирам.';

  @override
  String get tnFreeBronzeAdded => '🎉 Бесплатный бронзовый вход добавлен!';

  @override
  String get tnFreeEntryAd => 'Бесплатный вход (реклама)';

  @override
  String tnBuyEntry(Object price, Object tier) {
    return 'Купить $tier вход - $price';
  }

  @override
  String get acAll => 'Все';

  @override
  String get acUnlocked => 'Открытые';

  @override
  String get acLocked => 'Закрытые';

  @override
  String get acTotalUpper => 'ВСЕГО';

  @override
  String get acUnlockedUpper => 'ОТКРЫТО';

  @override
  String get acClaimedUpper => 'ПОЛУЧЕНО';

  @override
  String get acPendingUpper => 'ОЖИДАЕТ';

  @override
  String acPercentComplete(Object percent) {
    return '$percent% выполнено';
  }

  @override
  String acPercentOfUnlocked(Object percent) {
    return '$percent% от открытых';
  }

  @override
  String get acEmpty => 'Здесь нет достижений';

  @override
  String acXpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String acUnlockedDate(Object date) {
    return 'Открыто $date';
  }

  @override
  String get rpTitle => 'Повторы игр';

  @override
  String get rpRecent => 'Недавние';

  @override
  String get rpBest => 'Лучшие';

  @override
  String get rpCrashes => 'Столкновения';

  @override
  String get rpLoading => 'Загрузка повторов...';

  @override
  String get rpNoRecent => 'Нет недавних повторов';

  @override
  String get rpNoBest => 'Нет повторов с рекордами';

  @override
  String get rpNoCrashes => 'Нет повторов столкновений';

  @override
  String get rpEmptySub => 'Сыграйте пару игр, чтобы появились повторы!';

  @override
  String get rpScore => 'Счёт';

  @override
  String get rpDuration => 'Длительность';

  @override
  String get rpFood => 'Еда';

  @override
  String get rpFrames => 'Кадры';

  @override
  String get rpMaxLength => 'Макс. длина';

  @override
  String get rpWatch => 'Смотреть';

  @override
  String get rpYesterday => 'Вчера';

  @override
  String get rpDeleteTitle => 'Удалить повтор';

  @override
  String rpDeleteBody(Object date) {
    return 'Удалить повтор от $date?';
  }

  @override
  String get rpDelete => 'Удалить';

  @override
  String get rpDeleted => 'Повтор удалён';

  @override
  String get rpDeleteFailed => 'Не удалось удалить повтор';

  @override
  String get lbTitle => 'Рейтинги';

  @override
  String get lbGlobal => 'Мировой';

  @override
  String get lbWeekly => 'Недельный';

  @override
  String get lbWeeklySub =>
      'По вашему лучшему счёту за неделю (сброс в воскресенье)';

  @override
  String get lbGlobalSub => 'По вашему лучшему счёту за всё время';

  @override
  String lbScoreLine(Object score) {
    return 'Счёт: $score';
  }

  @override
  String get lbLoadingGlobal => 'Загрузка мирового рейтинга...';

  @override
  String get lbLoadingWeekly => 'Загрузка недельного рейтинга...';

  @override
  String get lbNoScores => 'Пока нет результатов';

  @override
  String get lbBeFirst => 'Станьте первым рекордсменом!';

  @override
  String get lbNoWeekly => 'На этой неделе результатов нет';

  @override
  String get lbPlayThisWeek => 'Сыграйте на этой неделе, чтобы попасть сюда!';

  @override
  String get lbAnonymous => 'Аноним';

  @override
  String get lbGuestBadge => 'ГОСТЬ';

  @override
  String get lbPts => 'очк.';

  @override
  String lbGamesPlayed(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'сыграно $count игры',
      many: 'сыграно $count игр',
      few: 'сыграно $count игры',
      one: 'сыграна $count игра',
    );
    return '$_temp0';
  }

  @override
  String bpClaimedToast(Object name) {
    return '$name — получено!';
  }

  @override
  String get bpTitle => 'Боевой пропуск';

  @override
  String get bpTitleUpper => 'БОЕВОЙ ПРОПУСК';

  @override
  String get bpLoading => 'Загрузка боевого пропуска...';

  @override
  String get bpWatchAdXp => 'Смотреть рекламу — +50 XP пропуска';

  @override
  String get bpXpEarned => '+50 XP боевого пропуска!';

  @override
  String get bpSeasonEnded => 'Сезон завершён';

  @override
  String bpHoursLeft(Object hours) {
    return 'осталось $hoursч';
  }

  @override
  String bpDaysLeft(Object days) {
    return 'осталось $daysд';
  }

  @override
  String get bpTierUpper => 'УРОВЕНЬ';

  @override
  String bpTierMax(Object max) {
    return ' / $max';
  }

  @override
  String get bpSeasonComplete => 'Сезон пройден';

  @override
  String get bpSeasonCompleteUpper => 'СЕЗОН ПРОЙДЕН';

  @override
  String bpXpProgress(Object next, Object tier, Object xp) {
    return '$xp / $next XP до уровня $tier';
  }

  @override
  String get bpPremiumBadge => 'ПРЕМИУМ';

  @override
  String get bpSeasonCosmicSerpent => 'Сезон «Космический змей»';

  @override
  String get bpUnlockedEverything => 'Вы открыли все уровни этого сезона.';

  @override
  String get bpComingNext => 'ДАЛЬШЕ';

  @override
  String bpTierN(Object tier) {
    return 'Уровень $tier';
  }

  @override
  String bpTiersAway(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'через $count уровня',
      many: 'через $count уровней',
      few: 'через $count уровня',
      one: 'через $count уровень',
    );
    return '$_temp0';
  }

  @override
  String get bpUnlockWithPro => 'ОТКРЫТЬ С PRO';

  @override
  String get bpAvailableNow => 'ДОСТУПНО СЕЙЧАС';

  @override
  String bpTierAbbrev(Object tier) {
    return 'У$tier';
  }

  @override
  String get bpClaim => 'ЗАБРАТЬ';

  @override
  String get bpPremiumWaiting => 'Премиум-награды ждут';

  @override
  String get bpSubscribeToClaim => 'Оформите Pro, чтобы забрать их.';

  @override
  String get bpHideTiers => 'Скрыть уровни';

  @override
  String bpViewAllTiers(Object count) {
    return 'Показать все $count уровней';
  }

  @override
  String get bpCollapse => 'СВЕРНУТЬ';

  @override
  String get bpExpand => 'РАЗВЕРНУТЬ';

  @override
  String get bpNow => 'ТЕКУЩИЙ';

  @override
  String bpTierUpperN(Object tier) {
    return 'УРОВЕНЬ $tier';
  }

  @override
  String get bpUnlocked => 'Открыто';

  @override
  String bpReachTier(Object tier) {
    return 'Достигните уровня $tier, чтобы открыть';
  }

  @override
  String get bpBetweenSeasons => 'Между сезонами';

  @override
  String get bpNoSeasonBody =>
      'Сейчас боевой пропуск не идёт — новый сезон начнётся автоматически. Загляните позже.';

  @override
  String get bpCheckNewSeason => 'Проверить новый сезон';

  @override
  String get pbActive => 'Премиум активен!';

  @override
  String get pbActiveSub => 'Вам доступны все премиум-функции';

  @override
  String get pbHeaderSub => 'Откройте всё, что есть в игре';

  @override
  String get pbMonthlyPlan => 'Месячный план';

  @override
  String get pbYearlyPlan => 'Годовой план';

  @override
  String get pbSave33 => 'Экономия 33%';

  @override
  String get pbMostPopular => 'САМЫЙ ПОПУЛЯРНЫЙ';

  @override
  String get pbFeatExtraLife => 'Всегда бесплатная доп. жизнь';

  @override
  String get pbFeatExtraLifeDesc =>
      'Разбились — играйте дальше: участники Pro мгновенно возрождаются бесплатно, без рекламы и монет, раз за игру';

  @override
  String get pbFeatNoAds => 'Уберите всю рекламу';

  @override
  String get pbFeatNoAdsDesc =>
      'Без баннеров и вставок — играйте совсем без рекламы, навсегда';

  @override
  String get pbFeatThemes => 'Все премиум-темы';

  @override
  String get pbFeatThemesDesc =>
      'Crystal, Cyberpunk, Space, Ocean, Desert, Forest';

  @override
  String get pbFeatSkins => 'Все премиум-скины';

  @override
  String get pbFeatSkinsDesc =>
      'Golden, Galaxy, Dragon, Electric, Fire, Ice и ещё 5';

  @override
  String get pbFeatTrails => 'Все премиум-следы';

  @override
  String get pbFeatTrailsDesc =>
      'Particle, Glow, Rainbow, Fire, Cosmic, Crystal и ещё 5';

  @override
  String get pbFeatBoards => 'Большие игровые поля';

  @override
  String get pbFeatBoardsDesc => 'Играйте на полях 35x35, 40x40 и 50x50';

  @override
  String get pbFeatCoins => 'Монеты 2x';

  @override
  String get pbFeatCoinsDesc => 'Вдвое больше монет Snake за каждую игру';

  @override
  String get pbFeatLucky => 'Счастливчик — больше особой еды';

  @override
  String get pbFeatLuckyDesc =>
      '+50% шанс появления редкой особой еды на 50 очков в каждой игре';

  @override
  String get pbFeatPowerUps => 'Больше усилений в игре';

  @override
  String get pbFeatPowerUpsDesc => '+30% к частоте появления усилений на поле';

  @override
  String get pbFeatBundle => 'Премиум-набор усилений';

  @override
  String get pbFeatBundleDesc =>
      '5× Teleport, Ghost Mode, Magnetic Food, Score Shield и Mega Invincibility каждый платёжный цикл';

  @override
  String get pbFeatTournament => 'Турнирные входы';

  @override
  String get pbFeatTournamentDesc =>
      '1× бронзовый + 1× серебряный + 1× золотой вход каждый платёжный цикл';

  @override
  String get pbIncludes => 'Премиум включает:';

  @override
  String get pbProPerk => 'БОНУС PRO';

  @override
  String pbSubscribeCta(Object period, Object price) {
    return 'Подписаться — $price$period';
  }

  @override
  String get pbReassurance =>
      'Без обязательств • Отмена в любой момент • Безопасная оплата';

  @override
  String get pbNotAvailable => 'Премиум-подписка недоступна';

  @override
  String get eaTitleLink => 'Сохраните прогресс';

  @override
  String get eaTitleSignIn => 'Вход по почте';

  @override
  String get eaExplainer =>
      'Добавьте почту и пароль к аккаунту, чтобы покупать, восстанавливаться после переустановки и входить с любого устройства.';

  @override
  String get eaLinkExisting => 'Привязать существующий';

  @override
  String get eaSignIn => 'Войти';

  @override
  String get eaCreateAccount => 'Создать аккаунт';

  @override
  String get eaForgotPassword => 'Забыли пароль?';

  @override
  String get eaLinkToExisting => 'Привязать к существующему аккаунту';

  @override
  String get eaMinChars => 'Не менее 8 символов';

  @override
  String eaMinCharsN(Object count) {
    return 'Не менее $count символов';
  }

  @override
  String get eaCreateAndLink => 'Создать и привязать аккаунт';

  @override
  String get eaEmail => 'Почта';

  @override
  String get eaEmailRequired => 'Укажите почту';

  @override
  String get eaEmailInvalid => 'Введите корректную почту';

  @override
  String get eaPassword => 'Пароль';

  @override
  String get eaPasswordRequired => 'Укажите пароль';

  @override
  String get eaForgotFirst =>
      'Сначала введите почту выше, затем нажмите «Забыли пароль».';

  @override
  String eaResetSent(Object email) {
    return 'Письмо для сброса пароля отправлено на $email.';
  }

  @override
  String get eaErrInvalidEmail => 'Этот адрес почты некорректен.';

  @override
  String get eaErrDisabled => 'Этот аккаунт отключён.';

  @override
  String get eaErrNoAccount => 'Аккаунт с этой почтой не найден.';

  @override
  String get eaErrWrongCreds => 'Неверная почта или пароль.';

  @override
  String get eaErrEmailInUse =>
      'Аккаунт с этой почтой уже существует. Попробуйте войти.';

  @override
  String get eaErrWeakPassword =>
      'Пароль слишком слабый. Используйте не менее 8 символов.';

  @override
  String get eaErrNotEnabled =>
      'Вход по почте/паролю не включён. Обратитесь в поддержку.';

  @override
  String get eaErrTooMany =>
      'Слишком много попыток. Подождите несколько минут и попробуйте снова.';

  @override
  String get eaErrNetwork => 'Ошибка сети. Проверьте соединение.';

  @override
  String get eaErrAlreadyLinked => 'Этот аккаунт уже привязан к почте/паролю.';

  @override
  String get eaErrRecentLogin =>
      'В целях безопасности войдите снова перед привязкой.';

  @override
  String get eaErrGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get faWelcome => 'Добро пожаловать в\nSnake Classic!';

  @override
  String get faChooseHow => 'Выберите, как хотите играть:';

  @override
  String get faSigningIn => 'Выполняется вход...';

  @override
  String get faSignInEmail => 'Войти по почте';

  @override
  String get faContinueGuest => 'Продолжить как гость';

  @override
  String get faGuestNote =>
      'Гости могут играть и сохранять прогресс локально, но не могут покупать. Войдите через Apple, Google или почту, когда решите подписаться или купить.';

  @override
  String get faPrivacyTerms => 'Конфиденциальность и условия';

  @override
  String get faReviewNote =>
      'Перед продолжением ознакомьтесь с политикой конфиденциальности и условиями использования';

  @override
  String get faAgreeCheckbox =>
      'Я прочитал(а) и принимаю политику конфиденциальности и условия использования';

  @override
  String get faContinueToSignIn => 'Перейти ко входу';

  @override
  String get faHeadsUp => 'Обратите внимание';

  @override
  String get faGuestBullet1 =>
      'Данные гостя автоматически удаляются с наших серверов после 90 дней неактивности.';

  @override
  String get faGuestBullet2 =>
      'Чтобы сохранить прогресс навсегда и играть на разных устройствах, войдите через Apple, Google или почту.';

  @override
  String get faGuestBullet3 =>
      'Гостевые аккаунты не могут покупать товары и подписки. Войдите, если хотите оформить Pro или купить косметику.';

  @override
  String get faChangedMind => 'Я передумал(а)';

  @override
  String get faProceedAnyway => 'Всё равно продолжить';

  @override
  String get faAppleFailed =>
      'Не удалось войти через Apple. Попробуйте ещё раз.';

  @override
  String get faGoogleFailed =>
      'Не удалось войти через Google. Попробуйте ещё раз.';

  @override
  String get faUnexpected =>
      'Произошла непредвиденная ошибка. Попробуйте ещё раз.';

  @override
  String get faGuestFailed =>
      'Не удалось продолжить как гость. Попробуйте ещё раз.';

  @override
  String get ldInitializing => 'Запуск Snake Classic...';

  @override
  String get ldTip1 =>
      'Думайте на два хода вперёд — хвост идёт туда, где только что была голова.';

  @override
  String get ldTip2 =>
      'Бонусная еда даёт больше очков, но быстро исчезает. Хватайте скорее!';

  @override
  String get ldTip3 =>
      'Разбились? Посмотрите короткую рекламу или потратьте монеты, чтобы возродиться и сохранить счёт.';

  @override
  String get ldTip4 => 'Ешьте без пауз, чтобы копить множитель комбо.';

  @override
  String get ldTip5 =>
      'Зажаты в углу? Идите вдоль стен, чтобы выиграть мгновение.';

  @override
  String get ldTip6 =>
      'Ежедневные задания и недельные квесты быстро приносят монеты.';

  @override
  String get ldTip7 =>
      'Snake Classic Pro открывает большие поля и убирает всю рекламу.';

  @override
  String get ldTip8 =>
      'Режим «На время» ценит скорость — а за рекламу дают +30 секунд.';

  @override
  String get ldTip9 =>
      'Усиления складываются: зарядите щит перед узким проходом.';

  @override
  String get ldTip10 =>
      'Меняйте темы, скины и следы в магазине в любой момент.';

  @override
  String get ldStepCore => 'Запуск основных систем...';

  @override
  String get ldStepCoreSub => 'Настройка соединения с сервером';

  @override
  String get ldStepProfile => 'Создание профиля игрока...';

  @override
  String get ldStepProfileSub => 'Генерация уникального имени';

  @override
  String get ldStepPrefs => 'Загрузка ваших настроек...';

  @override
  String get ldStepPrefsSub => 'Синхронизация тем и настроек';

  @override
  String get ldStepCloud => 'Синхронизация с облаком...';

  @override
  String get ldStepCloudSub => 'Проверка актуальности данных';

  @override
  String get ldStepGameData => 'Загрузка игровых данных...';

  @override
  String get ldStepGameDataSub => 'Получение игровых данных';

  @override
  String get ldStepAudio => 'Настройка аудиосистемы...';

  @override
  String get ldStepAudioSub => 'Загрузка звуковых эффектов';

  @override
  String get ldStepSetup => 'Проверка состояния настройки...';

  @override
  String get ldStepSetupSub => 'Почти готово!';

  @override
  String get ldWelcome => 'Добро пожаловать!';

  @override
  String get ldWelcomeSub => 'Выберите, как продолжить';

  @override
  String get ldReady => 'Готово к игре!';

  @override
  String get ldReadySub => 'С возвращением в Snake Classic';

  @override
  String ldInitFailed(Object error) {
    return 'Сбой запуска: $error';
  }

  @override
  String get ldRetrying => 'Повторный запуск...';

  @override
  String get ldTagline => 'ПРЕМИУМ-ЗМЕЙКА';

  @override
  String get ldLoadingUpper => 'ЗАГРУЗКА';

  @override
  String get ldDidYouKnow => 'А ВЫ ЗНАЛИ?';

  @override
  String get ldGameFeatures => 'ОСОБЕННОСТИ ИГРЫ';

  @override
  String get ldFeatFps => '60FPS';

  @override
  String get ldFeatFpsSub => 'Плавный геймплей';

  @override
  String get ldFeatEffects => 'ЭФФЕКТЫ';

  @override
  String get ldFeatEffectsSub => 'Визуальные частицы';

  @override
  String get ldFeatLevels => 'УРОВНИ';

  @override
  String get ldFeatLevelsSub => 'Растущий азарт';

  @override
  String get ldFeatAudio => 'ЗВУК';

  @override
  String get ldFeatAudioSub => 'Погружающий звук';

  @override
  String get ldFeatScores => 'ОЧКИ';

  @override
  String get ldFeatScoresSub => 'Мировые рейтинги';

  @override
  String get ldFeatThemes => 'ТЕМЫ';

  @override
  String get ldFeatThemesSub => 'Много стилей';

  @override
  String get ldDevelopedBy => 'РАЗРАБОТКА И ПОДДЕРЖКА';

  @override
  String get ldDevTagline => 'Создаём премиальные мобильные впечатления';

  @override
  String get ldInitFailedUpper => 'СБОЙ ЗАПУСКА';

  @override
  String get ldRetryUpper => 'ПОВТОРИТЬ';

  @override
  String get pgArena => 'Подготовка арены...';

  @override
  String get pgControls => 'Калибровка управления...';

  @override
  String get pgSnake => 'Появление змейки...';

  @override
  String get pgFood => 'Размещение еды...';

  @override
  String get pgPowerUps => 'Зарядка усилений...';

  @override
  String get pgAlmost => 'Почти готово...';

  @override
  String get pgGo => 'Вперёд!';

  @override
  String get pgTip1 =>
      'Держите направление дольше, чтобы копить множители комбо.';

  @override
  String get pgTip2 => 'Бонусная еда даёт больше очков, но быстро исчезает.';

  @override
  String get pgTip3 => 'Усиления появляются случайно — берите, пока можно.';

  @override
  String get pgTip4 => 'Думайте на два хода вперёд, а не на один.';

  @override
  String get pgTip5 =>
      'Длинные змейки поворачивают медленнее. Приберегите крутые виражи для старта.';

  @override
  String get pgTip6 =>
      'Множитель очков складывается с комбо — получаются гигантские счета.';

  @override
  String get pgTip7 =>
      'Особая еда редка — если появилась, берите первым делом.';

  @override
  String get pgTip8 => '«На время» быстро ускоряется. Рассчитывайте повороты.';

  @override
  String get pgTip9 =>
      'В Дзене стены проходимы. Используйте это, чтобы выбираться из ловушек.';

  @override
  String get pgTip10 =>
      'Идеальная игра: не заходите повторно на клетку, где было тело.';

  @override
  String get pgTip11 => 'D-Pad даёт точные повороты; свайп быстрее.';

  @override
  String get pgTip12 => 'Пауза в любой момент из HUD — таймер подождёт.';

  @override
  String get pgPreparing => 'ПОДГОТОВКА АРЕНЫ';

  @override
  String get pgTournamentMode => 'ТУРНИРНЫЙ РЕЖИМ';

  @override
  String get pgGameMode => 'РЕЖИМ ИГРЫ';

  @override
  String get pgDPadControls => 'Управление D-Pad';

  @override
  String get pgSwipeControls => 'Управление свайпами';

  @override
  String get pgLevel => 'УРОВЕНЬ';

  @override
  String get pgBest => 'РЕКОРД';

  @override
  String get pgGames => 'ИГРЫ';

  @override
  String get pgProTip => 'СОВЕТ ПРО';

  @override
  String get pgTapToStart => 'КОСНИТЕСЬ ЭКРАНА, ЧТОБЫ НАЧАТЬ';

  @override
  String get wtWelcomeTitle => 'Добро пожаловать в игру!';

  @override
  String get wtWelcomeMsg =>
      'Давайте научимся играть в Snake Classic. Этот быстрый урок покажет основы.';

  @override
  String get wtHudTitle => 'Игровая информация';

  @override
  String get wtHudMsg =>
      'Верхняя панель показывает счёт, уровень и рекорд. Следите за прогрессом во время игры!';

  @override
  String get wtControlsTitle => 'Управление';

  @override
  String get wtControlsMsg =>
      'Меняйте направление свайпом по полю, экранной крестовиной или стрелками.';

  @override
  String get wtPracticeRightTitle => 'Попробуйте — поверните ВПРАВО';

  @override
  String get wtPracticeRightMsg =>
      'Поверните вправо, чтобы продолжить. Свайп, крестовина или стрелки — подойдёт любой способ.';

  @override
  String get wtPracticeUpTitle => 'Отлично — теперь ВВЕРХ';

  @override
  String get wtPracticeUpMsg => 'Поверните вверх, чтобы продолжить.';

  @override
  String get wtFoodTitle => 'Ешьте и растите';

  @override
  String get wtFoodMsg =>
      'Ведите змейку к еде на поле. Каждый кусочек делает её длиннее!';

  @override
  String get wtComboTitle => 'Собирайте комбо';

  @override
  String get wtComboMsg =>
      'Ешьте, не умирая, чтобы собрать комбо. 5 укусов — 1,5×, 10 — 2×, 20 — 3×. Огненный чип у счёта разгорается и пульсирует по мере роста.';

  @override
  String get wtPowerUpsTitle => 'Усиления';

  @override
  String get wtPowerUpsMsg =>
      'Иногда появляются блестящие значки — съешьте, чтобы активировать. Кольцо вокруг значка тает по мере действия, а на паузе таймер замирает.';

  @override
  String get wtWallsTitle => 'Избегайте стен!';

  @override
  String get wtWallsMsg =>
      'Не врезайтесь в края поля - столкновение со стеной означает конец игры!';

  @override
  String get wtSelfTitle => 'Не врезайтесь в себя!';

  @override
  String get wtSelfMsg =>
      'Когда змейка вырастет, берегитесь столкновения с собственным телом!';

  @override
  String get wtPauseTitle => 'Пауза в любой момент';

  @override
  String get wtPauseMsg =>
      'Нажмите значок паузы, чтобы заморозить игру. Оттуда можно продолжить, начать заново, открыть гид по игре, повторить этот урок или переключить D-Pad.';

  @override
  String get wtReadyTitle => 'Вы готовы!';

  @override
  String get wtReadyMsg =>
      'Удачи! Открывайте гид по игре в меню паузы, чтобы читать про комбо, усиления, режимы и подсказки о столкновениях. Заглядывайте в профиль — там открываются достижения.';

  @override
  String get wtStartPlaying => 'Начать игру!';

  @override
  String get wtSkipTutorial => 'Пропустить обучение';

  @override
  String get wtSwipeRightUpper => 'ВПРАВО';

  @override
  String get wtSwipeLeftUpper => 'ВЛЕВО';

  @override
  String get wtSwipeUpUpper => 'ВВЕРХ';

  @override
  String get wtSwipeDownUpper => 'ВНИЗ';

  @override
  String get wtSwipeAnywhereScreen => 'Свайп, крестовина или стрелки';

  @override
  String get wtSwipeAnywhere => 'Ваш ход!';

  @override
  String get wtGotIt => 'Понятно!';

  @override
  String get wtNext => 'Дальше';

  @override
  String get wtSkip => 'Пропустить';

  @override
  String get wtWaiting => 'Ожидание...';

  @override
  String get hwPlayTitle => 'Добро пожаловать в Snake Classic!';

  @override
  String get hwPlayMsg =>
      'Нажмите ИГРАТЬ, чтобы начать. Управляйте змейкой свайпами и ешьте, чтобы расти!';

  @override
  String get hwCoinsTitle => 'Ваши монеты';

  @override
  String get hwCoinsMsg =>
      'Зарабатывайте монеты в играх, заданиях и за ежедневные бонусы. Тратьте их в магазине!';

  @override
  String get hwDailyTitle => 'Ежедневные задания';

  @override
  String get hwDailyMsg =>
      'Выполняйте ежедневные задания ради бонусных монет и наград. Каждый день новые!';

  @override
  String get hwStoreTitle => 'Магазин';

  @override
  String get hwStoreMsg =>
      'Покупайте темы, скины, следы и усиления за монеты. Оформите Pro ради премиум-полей и эксклюзивной косметики.';

  @override
  String get hwCosmeticsTitle => 'Скины и следы';

  @override
  String get hwCosmeticsMsg =>
      'Настройте змейку здесь. Скины меняют её облик; следы оставляют свечение позади. Получайте за монеты или открывайте с Pro.';

  @override
  String get hwProfileTitle => 'Ваш профиль';

  @override
  String get hwProfileMsg =>
      'Здесь статистика, достижения и рекорды. Достижения открываются на рубежах — некоторым нужен конкретный режим (Классика, Сложный и т.д.). Войдите, чтобы синхронизироваться между устройствами.';

  @override
  String get hwSettingsTitle => 'Настройки';

  @override
  String get hwSettingsMsg =>
      'Настройте игру под себя - темы, управление, звук и многое другое!';

  @override
  String get hudScoreUpper => 'СЧЁТ';

  @override
  String hudScoreSemantics(Object value) {
    return 'Счёт $value';
  }

  @override
  String hudLevelBadge(Object level) {
    return 'УР$level';
  }

  @override
  String get hudTournamentBadge => 'ТУРНИР';

  @override
  String hudComboMultiplier(Object multiplier) {
    return '${multiplier}x';
  }

  @override
  String get poPaused => 'ПАУЗА';

  @override
  String get poPremium => 'Премиум';

  @override
  String get poStore => 'Магазин';

  @override
  String get poResume => 'ПРОДОЛЖИТЬ';

  @override
  String get poRestart => 'ЗАНОВО';

  @override
  String get poHome => 'ДОМОЙ';

  @override
  String get poDPadOn => 'D-PAD: ВКЛ';

  @override
  String get poDPadOff => 'D-PAD: ВЫКЛ';

  @override
  String get poSound => 'ЗВУК';

  @override
  String get poMusic => 'МУЗЫКА';

  @override
  String get poHowToPlay => 'КАК ИГРАТЬ';

  @override
  String get poGameGuide => 'ГИД ПО ИГРЕ';

  @override
  String get poFoodUpper => 'ЕДА';

  @override
  String get poPts10 => '10 очк.';

  @override
  String get poPts25 => '25 очк.';

  @override
  String get poPts50 => '50 очк.';

  @override
  String get poComboUpper => 'КОМБО';

  @override
  String get poBites5 => '5 укусов';

  @override
  String get poBites10 => '10 укусов';

  @override
  String get poBites20 => '20 укусов';

  @override
  String get poComboHint =>
      'Огненный чип у счёта разгорается и пульсирует на каждом рубеже.';

  @override
  String get poPowerUpsUpper => 'УСИЛЕНИЯ';

  @override
  String get poDur7s => '7 с';

  @override
  String get poDur6s => '6 с';

  @override
  String get poDur10s => '10 с';

  @override
  String get poDur8s => '8 с';

  @override
  String get poScore2x => 'Очки 2×';

  @override
  String get poPowerUpHint =>
      'Кольцо вокруг значка тает до истечения. На паузе таймер замирает.';

  @override
  String get poCrashUpper => 'СТОЛКНОВЕНИЕ';

  @override
  String get poCrashHint =>
      'Красная волна бьёт в клетку, где вы погибли. При столкновении с собой задетый сегмент подсвечивается жёлтым.';

  @override
  String get poModesUpper => 'РЕЖИМЫ';

  @override
  String get poModeWallsOn => 'стены есть';

  @override
  String get poModeWallsOff => 'стен нет';

  @override
  String get poModeFastTick => 'быстрый темп';

  @override
  String get poModeThreeFoods => '3 еды сразу';

  @override
  String get poModeThreeLives => '3 жизни, ускоряется';

  @override
  String get poModeThreeMin => '3 минуты всего';

  @override
  String get poModeFrequentPowerUps => 'частые усиления';

  @override
  String get poModeDontCross => 'не пересекайте след';

  @override
  String get dcTitle => 'Ежедневные задания';

  @override
  String get dcNoChallenges => 'Нет доступных заданий';

  @override
  String get dcAllComplete => 'Всё выполнено!';

  @override
  String dcBonusCoins(Object count) {
    return '+$count бонус';
  }

  @override
  String crVersionLine(Object build, Object version) {
    return 'v$version · сборка $build';
  }

  @override
  String get crTagline => 'Классическая змейка в новом прочтении.';

  @override
  String get crChipModes => 'Режимы';

  @override
  String get crChipAchievements => 'Достижения';

  @override
  String get crChipDaily => 'Ежедневно';

  @override
  String get crChipLeaderboards => 'Рейтинги';

  @override
  String get crChipCosmetics => 'Косметика';

  @override
  String get crCraftedBy => 'Автор';

  @override
  String crCopyright(Object year) {
    return '© $year Pranta Dutta · Все права защищены';
  }

  @override
  String get gbSpeedNormal => 'Обычная';

  @override
  String get gbSpeedFast => 'Быстрая';

  @override
  String get gbSpeedFaster => 'Быстрее';

  @override
  String get gbSpeedBlazing => 'Жгучая';

  @override
  String get gbSpeedInsane => 'Безумная';

  @override
  String get gbSpeedMax => 'МАКС';

  @override
  String get gbLength => 'Длина';

  @override
  String get gbSpeed => 'Скорость';

  @override
  String get gbLevel => 'Уровень';

  @override
  String get rarityCommon => 'Обычное';

  @override
  String get rarityRare => 'Редкое';

  @override
  String get rarityEpic => 'Эпическое';

  @override
  String get rarityLegendary => 'Легендарное';

  @override
  String get rarityDiamond => 'Алмазное';

  @override
  String get achTitleFirstBite => 'Первый укус';

  @override
  String get achDescFirstBite => 'Наберите свой первый балл';

  @override
  String get achTitleGettingStarted => 'Начало пути';

  @override
  String get achDescGettingStarted => 'Наберите 100 очков';

  @override
  String get achTitleHighScorer => 'Хороший счёт';

  @override
  String get achDescHighScorer => 'Наберите 500 очков за одну игру';

  @override
  String get achTitleMasterScorer => 'Мастер очков';

  @override
  String get achDescMasterScorer => 'Наберите 1000 очков за одну игру';

  @override
  String get achTitleLegendaryScorer => 'Легендарный счёт';

  @override
  String get achDescLegendaryScorer => 'Наберите 2000 очков за одну игру';

  @override
  String get achTitleFirstGame => 'Первая игра';

  @override
  String get achDescFirstGame => 'Сыграйте свою первую игру';

  @override
  String get achTitleRegularPlayer => 'Постоянный игрок';

  @override
  String get achDescRegularPlayer => 'Сыграйте 10 игр';

  @override
  String get achTitleDedicatedPlayer => 'Преданный игрок';

  @override
  String get achDescDedicatedPlayer => 'Сыграйте 50 игр';

  @override
  String get achTitleSnakeEnthusiast => 'Энтузиаст змейки';

  @override
  String get achDescSnakeEnthusiast => 'Сыграйте 100 игр';

  @override
  String get achTitleSnakeAddict => 'Зависимый от змейки';

  @override
  String get achDescSnakeAddict => 'Сыграйте 500 игр';

  @override
  String get achTitleSurvivor => 'Выживший';

  @override
  String get achDescSurvivor => 'Продержитесь 60 секунд';

  @override
  String get achTitleEndurance => 'Выносливость';

  @override
  String get achDescEndurance => 'Продержитесь 2 минуты';

  @override
  String get achTitleMarathon => 'Марафон';

  @override
  String get achDescMarathon => 'Продержитесь 5 минут';

  @override
  String get achTitleNoWalls => 'Мимо стен';

  @override
  String get achDescNoWalls => 'Сыграйте 5 игр, не врезаясь в стены';

  @override
  String get achTitleSpeedster => 'Гонщик';

  @override
  String get achDescSpeedster => 'Достигните уровня 10 (максимальная скорость)';

  @override
  String get achTitlePerfectionist => 'Перфекционист';

  @override
  String get achDescPerfectionist => 'Завершите игру, не врезавшись в себя';

  @override
  String get achTitleAllFoodTypes => 'Гурман';

  @override
  String get achDescAllFoodTypes => 'Съешьте все 3 вида еды за одну игру';

  @override
  String get achTitleHalfGrand => 'Пять тысяч';

  @override
  String get achDescHalfGrand => 'Наберите 5 000 за одну игру';

  @override
  String get achTitleScoreSniper => 'Снайпер очков';

  @override
  String get achDescScoreSniper => 'Наберите 10 000 за одну игру';

  @override
  String get achTitleFiveDigitClub => 'Клуб пяти цифр';

  @override
  String get achDescFiveDigitClub => 'Наберите 25 000 за одну игру';

  @override
  String get achTitleScoreTycoon => 'Магнат очков';

  @override
  String get achDescScoreTycoon => 'Наберите 50 000 за одну игру';

  @override
  String get achTitleScoreGod => 'Бог очков';

  @override
  String get achDescScoreGod => 'Наберите 100 000 за одну игру';

  @override
  String get achTitlePointCollector => 'Коллекционер очков';

  @override
  String get achDescPointCollector => 'Накопите 10 000 очков за всё время';

  @override
  String get achTitlePointHoarder => 'Накопитель очков';

  @override
  String get achDescPointHoarder => 'Накопите 100 000 очков за всё время';

  @override
  String get achTitleHalfMillionClub => 'Клуб полумиллиона';

  @override
  String get achDescHalfMillionClub => 'Накопите 500 000 очков за всё время';

  @override
  String get achTitlePointMillionaire => 'Миллионер очков';

  @override
  String get achDescPointMillionaire => 'Накопите 1 000 000 очков за всё время';

  @override
  String get achTitleDecamillionaire => 'Декамиллионер';

  @override
  String get achDescDecamillionaire => 'Накопите 10 000 000 очков за всё время';

  @override
  String get achTitleSnakeVeteran => 'Ветеран змейки';

  @override
  String get achDescSnakeVeteran => 'Сыграйте 1 000 игр';

  @override
  String get achTitleSnakeLegend => 'Легенда змейки';

  @override
  String get achDescSnakeLegend => 'Сыграйте 5 000 игр';

  @override
  String get achTitleIronWill => 'Железная воля';

  @override
  String get achDescIronWill => 'Продержитесь 10 минут за одну игру';

  @override
  String get achTitleEternalSnake => 'Вечная змейка';

  @override
  String get achDescEternalSnake => 'Продержитесь 20 минут за одну игру';

  @override
  String get achTitleTimeLord => 'Повелитель времени';

  @override
  String get achDescTimeLord => 'Продержитесь 30 минут за одну игру';

  @override
  String get achTitleFirstBiteSnack => 'Первый перекус';

  @override
  String get achDescFirstBiteSnack => 'Съешьте 5 единиц еды за игру';

  @override
  String get achTitleHungrySnake => 'Голодная змейка';

  @override
  String get achDescHungrySnake => 'Съешьте 20 единиц еды за игру';

  @override
  String get achTitleFamished => 'Изголодавшийся';

  @override
  String get achDescFamished => 'Съешьте 50 единиц еды за игру';

  @override
  String get achTitleRavenous => 'Прожорливый';

  @override
  String get achDescRavenous => 'Съешьте 100 единиц еды за игру';

  @override
  String get achTitleInsatiable => 'Ненасытный';

  @override
  String get achDescInsatiable => 'Съешьте 200 единиц еды за игру';

  @override
  String get achTitleBlackHoleStomach => 'Желудок — чёрная дыра';

  @override
  String get achDescBlackHoleStomach => 'Съешьте 500 единиц еды за игру';

  @override
  String get achTitleFoodieApprentice => 'Начинающий гурман';

  @override
  String get achDescFoodieApprentice => 'Съешьте 100 единиц еды за всё время';

  @override
  String get achTitleFoodiePro => 'Гурман-профи';

  @override
  String get achDescFoodiePro => 'Съешьте 1 000 единиц еды за всё время';

  @override
  String get achTitleFoodieMaster => 'Мастер-гурман';

  @override
  String get achDescFoodieMaster => 'Съешьте 10 000 единиц еды за всё время';

  @override
  String get achTitleFoodieGod => 'Бог-гурман';

  @override
  String get achDescFoodieGod => 'Съешьте 50 000 единиц еды за всё время';

  @override
  String get achTitleQuickPlayer => 'Быстрый игрок';

  @override
  String get achDescQuickPlayer => 'Играйте 1 час в сумме';

  @override
  String get achTitleEngagedPlayer => 'Увлечённый игрок';

  @override
  String get achDescEngagedPlayer => 'Играйте 10 часов в сумме';

  @override
  String get achTitleHardcorePlayer => 'Хардкорный игрок';

  @override
  String get achDescHardcorePlayer => 'Играйте 50 часов в сумме';

  @override
  String get achTitleSnakeObsessed => 'Одержимый змейкой';

  @override
  String get achDescSnakeObsessed => 'Играйте 100 часов в сумме';

  @override
  String get achTitleTouchGrass => 'Потрогай траву';

  @override
  String get achDescTouchGrass =>
      'Играйте 250 часов в сумме — может, пора на улицу?';

  @override
  String get achTitleLevel5 => 'Ученик';

  @override
  String get achDescLevel5 => 'Достигните 5-го уровня';

  @override
  String get achTitleLevel10 => 'Подмастерье';

  @override
  String get achDescLevel10 => 'Достигните 10-го уровня';

  @override
  String get achTitleLevel25 => 'Эксперт';

  @override
  String get achDescLevel25 => 'Достигните 25-го уровня';

  @override
  String get achTitleLevel50 => 'Мастер';

  @override
  String get achDescLevel50 => 'Достигните 50-го уровня';

  @override
  String get achTitleLevel100 => 'Гроссмейстер';

  @override
  String get achDescLevel100 => 'Достигните 100-го уровня';

  @override
  String get achTitleClassicInitiate => 'Новичок классики';

  @override
  String get achDescClassicInitiate => 'Завершите 10 игр в классическом режиме';

  @override
  String get achTitleClassicVeteran => 'Ветеран классики';

  @override
  String get achDescClassicVeteran => 'Завершите 100 игр в классическом режиме';

  @override
  String get achTitleClassic1000 => 'Знаток классики';

  @override
  String get achDescClassic1000 => 'Наберите 1 000 в классическом режиме';

  @override
  String get achTitleClassic5000 => 'Маэстро классики';

  @override
  String get achDescClassic5000 => 'Наберите 5 000 в классическом режиме';

  @override
  String get achTitleZenInitiate => 'Новичок дзена';

  @override
  String get achDescZenInitiate => 'Завершите 10 игр в режиме «Дзен»';

  @override
  String get achTitleZenGarden => 'Сад дзен';

  @override
  String get achDescZenGarden => 'Наберите 500 в режиме «Дзен»';

  @override
  String get achTitleZenMaster => 'Мастер дзена';

  @override
  String get achDescZenMaster => 'Наберите 5 000 в режиме «Дзен»';

  @override
  String get achTitleSpeedInitiate => 'Жажда скорости';

  @override
  String get achDescSpeedInitiate => 'Завершите 10 игр «Скоростного вызова»';

  @override
  String get achTitleSpeedrunner => 'Спидраннер';

  @override
  String get achDescSpeedrunner => 'Наберите 500 в «Скоростном вызове»';

  @override
  String get achTitleLightning => 'Молния';

  @override
  String get achDescLightning => 'Наберите 2 000 в «Скоростном вызове»';

  @override
  String get achTitleMultifoodInitiate => 'Мир еды';

  @override
  String get achDescMultifoodInitiate => 'Завершите 10 игр «Мультиеды»';

  @override
  String get achTitleBuffet => 'Буфет';

  @override
  String get achDescBuffet => 'Наберите 1 000 в «Мультиеде»';

  @override
  String get achTitleSmorgasbord => 'Пир';

  @override
  String get achDescSmorgasbord => 'Наберите 5 000 в «Мультиеде»';

  @override
  String get achTitleSurvivalInitiate => 'Новичок выживания';

  @override
  String get achDescSurvivalInitiate => 'Завершите 10 игр «Выживания»';

  @override
  String get achTitleSurvivalPro => 'Профи выживания';

  @override
  String get achDescSurvivalPro => 'Продержитесь 5 минут в режиме «Выживание»';

  @override
  String get achTitleLastSnakeStanding => 'Последняя змейка';

  @override
  String get achDescLastSnakeStanding => 'Наберите 2 500 в «Выживании»';

  @override
  String get achTitleTimeattackInitiate => 'Атакующий время';

  @override
  String get achDescTimeattackInitiate => 'Завершите 10 игр «На время»';

  @override
  String get achTitleBeatTheClock => 'Обгони часы';

  @override
  String get achDescBeatTheClock =>
      'Продержитесь все 3 минуты режима «На время»';

  @override
  String get achTitleTimeattackMaster => 'Мастер режима «На время»';

  @override
  String get achDescTimeattackMaster => 'Наберите 3 000 в режиме «На время»';

  @override
  String get achTitleComboStarter => 'Начинающий комбо';

  @override
  String get achDescComboStarter => 'Сделайте комбо 5x за одну игру';

  @override
  String get achTitleComboMaster => 'Мастер комбо';

  @override
  String get achDescComboMaster => 'Сделайте комбо 10x за одну игру';

  @override
  String get achTitleComboPro => 'Профи комбо';

  @override
  String get achDescComboPro => 'Сделайте комбо 20x за одну игру';

  @override
  String get achTitleComboGod => 'Бог комбо';

  @override
  String get achDescComboGod => 'Сделайте комбо 50x за одну игру';

  @override
  String get achTitleComboLegend => 'Легенда комбо';

  @override
  String get achDescComboLegend => 'Сделайте комбо 100x за одну игру';

  @override
  String get achTitleGrowingSnake => 'Растущая змейка';

  @override
  String get achDescGrowingSnake => 'Вырастите змейку до длины 20';

  @override
  String get achTitleBigSnake => 'Большая змейка';

  @override
  String get achDescBigSnake => 'Вырастите змейку до длины 50';

  @override
  String get achTitleHugeSnake => 'Огромная змейка';

  @override
  String get achDescHugeSnake => 'Вырастите змейку до длины 100';

  @override
  String get achTitleMassiveSnake => 'Гигантская змейка';

  @override
  String get achDescMassiveSnake => 'Вырастите змейку до длины 200';

  @override
  String get achTitleAnaconda => 'Анаконда';

  @override
  String get achDescAnaconda => 'Вырастите змейку до длины 500';

  @override
  String get achTitleFirstPowerUp => 'Усиление!';

  @override
  String get achDescFirstPowerUp => 'Соберите своё первое усиление';

  @override
  String get achTitlePowerPlayer => 'Игрок силы';

  @override
  String get achDescPowerPlayer => 'Соберите 10 усилений за всё время';

  @override
  String get achTitlePowerHungry => 'Жаждущий силы';

  @override
  String get achDescPowerHungry => 'Соберите 50 усилений за всё время';

  @override
  String get achTitlePowerAddict => 'Зависимый от силы';

  @override
  String get achDescPowerAddict => 'Соберите 200 усилений за всё время';

  @override
  String get achTitlePowerMaster => 'Мастер силы';

  @override
  String get achDescPowerMaster => 'Соберите 1 000 усилений за всё время';

  @override
  String get achTitleVarietyPack => 'Полный набор';

  @override
  String get achDescVarietyPack =>
      'Соберите каждое из 4 усилений хотя бы по разу';

  @override
  String get achTitleSpeedDemon => 'Демон скорости';

  @override
  String get achDescSpeedDemon => 'Соберите 25 усилений «Ускорение»';

  @override
  String get achTitleImmortalStreak => 'Бессмертная серия';

  @override
  String get achDescImmortalStreak => 'Соберите 25 усилений «Неуязвимость»';

  @override
  String get achTitleSpecialDiet => 'Особая диета';

  @override
  String get achDescSpecialDiet => 'Съешьте 50 особой еды за всё время';

  @override
  String get achTitleBonusHunter => 'Охотник за бонусами';

  @override
  String get achDescBonusHunter => 'Съешьте 100 бонусной еды за всё время';

  @override
  String get achTitleUntouchable5 => 'Неприкасаемый';

  @override
  String get achDescUntouchable5 =>
      'Завершите 5 идеальных игр (без столкновений, 30 с+)';

  @override
  String get achTitleUntouchable20 => 'Безупречный';

  @override
  String get achDescUntouchable20 => 'Завершите 20 идеальных игр';

  @override
  String get achTitleUntouchable50 => 'Легенда без единой ошибки';

  @override
  String get achDescUntouchable50 => 'Завершите 50 идеальных игр';

  @override
  String get achTitleHotStreak => 'Горячая серия';

  @override
  String get achDescHotStreak =>
      '5 игр подряд со счётом >0 и длительностью 30 с+';

  @override
  String get achTitleOnFire => 'В ударе';

  @override
  String get achDescOnFire => 'Серия из 10 игр (каждая 30 с+)';

  @override
  String get achTitleUnstoppable => 'Неудержимый';

  @override
  String get achDescUnstoppable => 'Серия из 25 игр (каждая 30 с+)';

  @override
  String get achTitleDailyThree => 'Ежедневный игрок';

  @override
  String get achDescDailyThree => 'Играйте 3 дня подряд';

  @override
  String get achTitleWeekWarrior => 'Воин недели';

  @override
  String get achDescWeekWarrior => 'Играйте 7 дней подряд';

  @override
  String get achTitleVelocity => 'Скорость';

  @override
  String get achDescVelocity => 'Достигните 15-го игрового уровня за одну игру';

  @override
  String get achTitleMachSpeed => 'Скорость Маха';

  @override
  String get achDescMachSpeed =>
      'Достигните 20-го игрового уровня за одну игру';

  @override
  String get achTitleCosmicSnake => 'Космическая змейка';

  @override
  String get achDescCosmicSnake =>
      'Достигните 25-го игрового уровня за одну игру';

  @override
  String get achTitleModeExplorer => 'Исследователь режимов';

  @override
  String get achDescModeExplorer =>
      'Сыграйте хотя бы одну игру в 3 разных режимах';

  @override
  String get achTitleAllModePlayer => 'Игрок всех режимов';

  @override
  String get achDescAllModePlayer =>
      'Сыграйте хотя бы одну игру в каждом режиме (8 режимов)';

  @override
  String get achTitleNightOwl => 'Сова';

  @override
  String get achDescNightOwl => 'Завершите игру между полуночью и 5 утра';

  @override
  String get achTitleEarlyBird => 'Жаворонок';

  @override
  String get achDescEarlyBird => 'Завершите игру между 5 и 8 утра';

  @override
  String get achTitleWeekendWarrior => 'Воин выходных';

  @override
  String get achDescWeekendWarrior => 'Завершите 10 игр в выходные';

  @override
  String get ppuMegaSpeedBoost => 'Мега-ускорение';

  @override
  String get ppuMegaInvincibility => 'Мега-неуязвимость';

  @override
  String get ppuMegaScoreMultiplier => 'Мега-множитель очков';

  @override
  String get ppuMegaSlowMotion => 'Мега-замедление';

  @override
  String get ppuTeleport => 'Телепорт';

  @override
  String get ppuSizeReducer => 'Уменьшитель размера';

  @override
  String get ppuScoreShield => 'Щит очков';

  @override
  String get ppuComboMultiplier => 'Множитель комбо';

  @override
  String get ppuTimeWarp => 'Искажение времени';

  @override
  String get ppuMagneticFood => 'Магнитная еда';

  @override
  String get ppuGhostMode => 'Режим призрака';

  @override
  String get ppuDoubleTrouble => 'Двойная беда';

  @override
  String get ppuLuckyCharm => 'Талисман удачи';

  @override
  String get ppuPowerSurge => 'Всплеск силы';

  @override
  String get bundleMegaPack => 'Мега-набор силы';

  @override
  String get bundleMegaPackDesc => 'Улучшенные версии классических усилений';

  @override
  String get bundleTacticalPack => 'Тактический набор';

  @override
  String get bundleTacticalPackDesc =>
      'Стратегические усиления для умелых игроков';

  @override
  String get bundleUltimatePack => 'Абсолютный набор';

  @override
  String get bundleUltimatePackDesc => 'Все премиум-усиления сразу';

  @override
  String get skinClassic => 'Классическая';

  @override
  String get skinGolden => 'Золотая змейка';

  @override
  String get skinRainbow => 'Радужная змейка';

  @override
  String get skinGalaxy => 'Галактическая змейка';

  @override
  String get skinDragon => 'Змейка-дракон';

  @override
  String get skinElectric => 'Электрическая змейка';

  @override
  String get skinFire => 'Огненная змейка';

  @override
  String get skinIce => 'Ледяная змейка';

  @override
  String get skinShadow => 'Теневая змейка';

  @override
  String get skinNeon => 'Неоновая змейка';

  @override
  String get skinCrystal => 'Хрустальная змейка';

  @override
  String get skinCosmic => 'Космическая змейка';

  @override
  String get skinClassicDesc => 'Оригинальный облик змейки';

  @override
  String get skinGoldenDesc =>
      'Сверкающая золотая змейка, блестящая при каждом движении';

  @override
  String get skinRainbowDesc =>
      'Разноцветная змейка, переливающаяся цветами радуги';

  @override
  String get skinGalaxyDesc => 'Космическая змейка со звёздными узорами';

  @override
  String get skinDragonDesc =>
      'Грозная змейка в драконьей чешуе с мистической силой';

  @override
  String get skinElectricDesc => 'Потрескивает электрической энергией';

  @override
  String get skinFireDesc => 'Пылает огненными узорами';

  @override
  String get skinIceDesc => 'Замёрзшая красота с кристальными эффектами';

  @override
  String get skinShadowDesc => 'Тёмная и загадочная теневая змейка';

  @override
  String get skinNeonDesc => 'Светится неоновыми огнями в стиле киберпанк';

  @override
  String get skinCrystalDesc =>
      'Полупрозрачная хрустальная змейка с призматическими эффектами';

  @override
  String get skinCosmicDesc => 'Змейка из звёздной пыли и космической материи';

  @override
  String get trailNone => 'Без следа';

  @override
  String get trailParticle => 'След из частиц';

  @override
  String get trailGlow => 'Светящийся след';

  @override
  String get trailRainbow => 'Радужный след';

  @override
  String get trailFire => 'Огненный след';

  @override
  String get trailElectric => 'Электрический след';

  @override
  String get trailStar => 'Звёздный след';

  @override
  String get trailCosmic => 'Космический след';

  @override
  String get trailNeon => 'Неоновый след';

  @override
  String get trailShadow => 'Теневой след';

  @override
  String get trailCrystal => 'Хрустальный след';

  @override
  String get trailDragon => 'Драконий след';

  @override
  String get trailNoneDesc => 'Чистая змейка без эффектов следа';

  @override
  String get trailParticleDesc => 'Оставляет след из сверкающих частиц';

  @override
  String get trailGlowDesc => 'Светящийся след, тающий позади змейки';

  @override
  String get trailRainbowDesc => 'Разноцветный радужный след';

  @override
  String get trailFireDesc => 'Пылающий огненный след с угольками';

  @override
  String get trailElectricDesc =>
      'Потрескивающий электрический след с молниями';

  @override
  String get trailStarDesc => 'Мерцающие звёзды следуют по пути змейки';

  @override
  String get trailCosmicDesc => 'Эффекты космической пыли и туманности';

  @override
  String get trailNeonDesc => 'Яркое неоновое свечение в стиле киберпанк';

  @override
  String get trailShadowDesc => 'Тёмный теневой след с дымкой';

  @override
  String get trailCrystalDesc => 'Тающие кристальные осколки';

  @override
  String get trailDragonDesc => 'Мистический след драконьего дыхания';

  @override
  String get coinPackSmall => 'Стартовый набор';

  @override
  String get coinPackMedium => 'Выгодный набор';

  @override
  String get coinPackLarge => 'Премиум-набор';

  @override
  String get coinPackMega => 'Абсолютный набор';

  @override
  String coinsAmount(Object coins) {
    return '$coins монет';
  }

  @override
  String coinsAmountBonus(Object coins, Object bonus) {
    return '$coins + $bonus бонусом';
  }

  @override
  String get boardSmall => 'Маленькое';

  @override
  String get boardClassic => 'Классическое';

  @override
  String get boardLarge => 'Большое';

  @override
  String get boardHuge => 'Огромное';

  @override
  String get boardEpic => 'Эпическое';

  @override
  String get boardMassive => 'Гигантское';

  @override
  String get boardUltimate => 'Абсолютное';

  @override
  String get boardSmallDesc => 'Быстрые игры, тесные пространства';

  @override
  String get boardClassicDesc => 'Оригинальный опыт «Змейки»';

  @override
  String get boardLargeDesc => 'Больше места для роста';

  @override
  String get boardHugeDesc => 'Максимум вызова и пространства';

  @override
  String get boardEpicDesc => 'Большое поле для опытных игроков';

  @override
  String get boardMassiveDesc => 'Громадное поле для эпичных игр';

  @override
  String get boardUltimateDesc => 'Самое большое возможное поле';

  @override
  String get crashLabelSkip => 'Пропустить';

  @override
  String get crashLabelUntilTap => 'До касания';

  @override
  String get tgmClassic => 'Классика';

  @override
  String get tgmSpeedRun => 'Скоростной забег';

  @override
  String get tgmSurvival => 'Выживание';

  @override
  String get tgmNoWalls => 'Без стен';

  @override
  String get tgmPowerUpMadness => 'Безумие усилений';

  @override
  String get tgmPerfectGame => 'Идеальная игра';

  @override
  String get tgmClassicDesc => 'Стандартные правила «Змейки»';

  @override
  String get tgmSpeedRunDesc => 'Скорость игры быстро растёт';

  @override
  String get tgmSurvivalDesc => 'Продержитесь как можно дольше';

  @override
  String get tgmNoWallsDesc => 'Змейка проходит сквозь края экрана';

  @override
  String get tgmPowerUpMadnessDesc => 'Усиления появляются часто';

  @override
  String get tgmPerfectGameDesc =>
      'Ошибки запрещены — одно столкновение завершает игру';

  @override
  String get ttDaily => 'Ежедневный вызов';

  @override
  String get ttWeekly => 'Еженедельный турнир';

  @override
  String get ttSpecial => 'Особое событие';

  @override
  String get tsUpcoming => 'Скоро';

  @override
  String get tsActive => 'Идёт';

  @override
  String get tsEnded => 'Завершён';

  @override
  String get cdEasy => 'Легко';

  @override
  String get cdMedium => 'Средне';

  @override
  String get cdHard => 'Сложно';

  @override
  String get usOnline => 'В сети';

  @override
  String get usOffline => 'Не в сети';

  @override
  String get usPlaying => 'Играет';

  @override
  String get bprXpBoost => 'Буст опыта';

  @override
  String get bprCoins => 'Монеты';

  @override
  String get bprTheme => 'Тема';

  @override
  String get bprSkin => 'Скин змейки';

  @override
  String get bprTrail => 'Эффект следа';

  @override
  String get bprPowerUp => 'Усиление';

  @override
  String get bprTournamentEntry => 'Входной билет на турнир';

  @override
  String get bprTitle => 'Титул игрока';

  @override
  String get bprAvatar => 'Аватар';

  @override
  String get bprSpecial => 'Особая награда';

  @override
  String get bprFree => 'Бесплатно';

  @override
  String get bprPremium => 'Премиум';

  @override
  String get bprnStarDust => 'Звёздная пыль';

  @override
  String get bprnEnergyPack => 'Энергетический набор';

  @override
  String get bprnBronzeEntry => 'Бронзовый билет';

  @override
  String get bprnSilverEntry => 'Серебряный билет';

  @override
  String get bprnStargazer => 'Звездочёт';

  @override
  String get bprnVoyager => 'Странник';

  @override
  String get bprnNebulaTheme => 'Тема «Туманность»';

  @override
  String get bprnStardustTrail => 'След звёздной пыли';

  @override
  String get bprnLegendaryCrate => 'Легендарный сундук';

  @override
  String get bprnMegaXp => 'Мега-опыт';

  @override
  String get bprnCosmicCharge => 'Космический заряд';

  @override
  String get bprnNovaBurst => 'Вспышка новой';

  @override
  String get bprnGalaxySkin => 'Скин «Галактика»';

  @override
  String get bprnCrystalSerpent => 'Хрустальный змей';

  @override
  String get bprnPlasmaWake => 'Плазменный шлейф';

  @override
  String get bprnCosmicAura => 'Космическая аура';

  @override
  String get bprnCyberpunkTheme => 'Тема «Киберпанк»';

  @override
  String get bprnCrystalTheme => 'Тема «Кристалл»';

  @override
  String get bprnSeasonTrophy => 'Трофей сезона';

  @override
  String get bprnCosmicCrown => 'Космическая корона';

  @override
  String get bprnCosmicLegend => 'Космическая легенда';

  @override
  String get bprnStarCommander => 'Звёздный командир';

  @override
  String bpRewardQtyCoins(Object quantity) {
    return '$quantity монет';
  }

  @override
  String bpRewardTypeQty(Object type, Object quantity) {
    return '$type x$quantity';
  }

  @override
  String bpRewardDescFree(Object type) {
    return 'Бесплатная награда: $type';
  }

  @override
  String bpRewardDescPremium(Object type) {
    return 'Эксклюзивная премиум-награда: $type';
  }

  @override
  String get insHowToPlay => 'КАК ИГРАТЬ';

  @override
  String get insObjective => 'ЦЕЛЬ';

  @override
  String get insObjectiveBody =>
      'Управляйте змейкой, ешьте еду и растите как можно длиннее, не врезаясь в стены и в себя!';

  @override
  String get insControls => 'УПРАВЛЕНИЕ';

  @override
  String get insSwipeUp => 'Свайп вверх ↑';

  @override
  String get insSwipeUpDesc => 'Двигает змейку вверх';

  @override
  String get insSwipeDown => 'Свайп вниз ↓';

  @override
  String get insSwipeDownDesc => 'Двигает змейку вниз';

  @override
  String get insSwipeLeft => 'Свайп влево ←';

  @override
  String get insSwipeLeftDesc => 'Двигает змейку влево';

  @override
  String get insSwipeRight => 'Свайп вправо →';

  @override
  String get insSwipeRightDesc => 'Двигает змейку вправо';

  @override
  String get insArrowKeys => 'Стрелки';

  @override
  String get insArrowKeysDesc => 'Сменить направление';

  @override
  String get insWasd => 'WASD';

  @override
  String get insWasdDesc => 'Сменить направление';

  @override
  String get insSpacebar => 'Пробел';

  @override
  String get insSpacebarDesc => 'Пауза/продолжение игры';

  @override
  String get insFoodTypes => 'ВИДЫ ЕДЫ';

  @override
  String get insNormalFood => 'Обычная еда';

  @override
  String get insBonusFood => 'Бонусная еда';

  @override
  String get insSpecialFood => 'Особая еда';

  @override
  String get insRules => 'ПРАВИЛА';

  @override
  String get insRule1 => 'Ешьте еду, чтобы расти и набирать очки';

  @override
  String get insRule2 => 'Змейка ускоряется с каждым уровнем';

  @override
  String get insRule3 =>
      'Игра заканчивается при столкновении со стеной или собой';

  @override
  String get insRule4 => 'Особая еда появляется каждые 10 обычных';

  @override
  String get insRule5 => 'Бонусная еда исчезает через 15 секунд';

  @override
  String get insProTips => 'СОВЕТЫ ПРО';

  @override
  String get insTip1 => 'Планируйте ходы заранее';

  @override
  String get insTip2 => 'Используйте края для безопасных зон';

  @override
  String get insTip3 => 'Следите за визуальными подсказками свайпов';

  @override
  String get insTip4 => 'Тренируйтесь на разных уровнях сложности';

  @override
  String get insBackToGame => 'НАЗАД К ИГРЕ';

  @override
  String dchClaimedReward(Object coins, Object xp) {
    return 'Получено $coins монет и $xp опыта!';
  }

  @override
  String dchClaimedCoins(Object coins) {
    return 'Получено $coins монет!';
  }

  @override
  String get dchWatchTo2x => 'СМОТРЕТЬ ЗА 2×';

  @override
  String dchDoubledBonus(Object coins) {
    return '🎉 Удвоено! +$coins бонусных монет!';
  }

  @override
  String get dchClaimAll => 'Забрать всё';

  @override
  String get dchTodaysProgress => 'Прогресс за сегодня';

  @override
  String get dchClaim => 'Забрать';

  @override
  String get dchClaimed => 'Получено';

  @override
  String get dchAllCompleteTitle => 'Все вызовы выполнены!';

  @override
  String get dchBonusClaimed => 'Бонусная награда получена';

  @override
  String get dchBonusPending => 'Бонус ждёт — заберите любой вызов';

  @override
  String get dchLoading => 'Загрузка вызовов...';

  @override
  String get dchCheckBack => 'Загляните позже за новыми ежедневными вызовами!';

  @override
  String get dchAbout => 'О ежедневных вызовах';

  @override
  String get dchAbout1 => 'Новые вызовы каждый день в полночь';

  @override
  String get dchAbout2 => 'Выполняйте вызовы и зарабатывайте монеты';

  @override
  String get dchAbout3 => 'Получайте опыт и повышайте уровень профиля';

  @override
  String get dchAbout4 => 'Выполните все 3 и получите бонусную награду!';

  @override
  String get dchAllBonusTitle => 'Бонус за все вызовы';

  @override
  String get dchAllBonusDesc => 'Выполнены все ежедневные вызовы за сегодня.';

  @override
  String get wqNoQuests =>
      'Еженедельных заданий пока нет — загляните в понедельник';

  @override
  String get wqTitle => 'Еженедельные задания';

  @override
  String get wqClaimReward => 'Забрать награду';

  @override
  String get rvNotFound => 'Повтор не найден';

  @override
  String get rvLoadFailed => 'Не удалось загрузить повтор';

  @override
  String rvTitle(Object name) {
    return 'Повтор: $name';
  }

  @override
  String get rvLoadingTitle => 'Загрузка повтора...';

  @override
  String get rvLoading => 'Загрузка повтора...';

  @override
  String get rvGoBack => 'Назад';

  @override
  String get rvScore => 'Очки';

  @override
  String get rvLevel => 'Уровень';

  @override
  String get rvFrame => 'Кадр';

  @override
  String get rvTime => 'Время';

  @override
  String get rvNoFrameData => 'Нет данных кадров';

  @override
  String get rvSpeedLabel => 'Скорость: ';

  @override
  String rvAteFood(Object type) {
    return '🍎 Съедена еда: $type';
  }

  @override
  String rvCollectedPowerUp(Object type) {
    return '⚡ Подобрано усиление: $type';
  }

  @override
  String get unEmpty => 'Имя пользователя не может быть пустым';

  @override
  String get unSetFailed => 'Не удалось установить имя пользователя';

  @override
  String get unPickTitle => 'Выберите имя пользователя';

  @override
  String get unPickBody =>
      'Под этим именем вы будете в таблице лидеров. Мы подобрали вам одно — оставьте или измените.';

  @override
  String get unLabel => 'Имя пользователя';

  @override
  String get unSaving => 'СОХРАНЕНИЕ...';

  @override
  String get unContinue => 'ПРОДОЛЖИТЬ';

  @override
  String get unChangeAnytime =>
      'Вы можете изменить его в любой момент в настройках.';

  @override
  String unMinLength(Object min) {
    return 'Имя пользователя должно содержать не менее $min символов';
  }

  @override
  String unMaxLength(Object max) {
    return 'Имя пользователя должно содержать не более $max символов';
  }

  @override
  String get unPattern =>
      'Имя должно начинаться с буквы и содержать только буквы, цифры и подчёркивания';

  @override
  String get unReserved => 'Это имя пользователя зарезервировано и недоступно';

  @override
  String get unTaken => 'Это имя пользователя уже занято';

  @override
  String get unUpdateFailed => 'Не удалось обновить имя пользователя';

  @override
  String get pcTitle => 'Обновлены конфиденциальность и условия';

  @override
  String pcVersionLine(Object version) {
    return 'Версия $version · ознакомьтесь и примите, чтобы продолжить';
  }

  @override
  String get pcTabPrivacy => 'Политика конфиденциальности';

  @override
  String get pcTabTerms => 'Условия использования';

  @override
  String get pcAgree =>
      'Я прочитал(а) и принимаю обновлённые Политику конфиденциальности и Условия использования';

  @override
  String get pcContinue => 'Продолжить';

  @override
  String lgAvailableAt(Object url) {
    return 'Документ доступен по адресу $url.';
  }

  @override
  String get lgUnavailable => 'Документ сейчас недоступен. Попробуйте позже.';

  @override
  String get auTitle => 'Зарегистрируйтесь для покупок';

  @override
  String get auBody =>
      'Гостевые аккаунты могут играть и сохранять прогресс локально, но не могут покупать и оформлять подписку. Привяжите Google или почту, чтобы открыть покупки — ваши монеты, косметика и рекорды сохранятся.';

  @override
  String get auGoogle => 'Продолжить с Google';

  @override
  String get auGoogleSub =>
      'Самый быстрый способ. Войдите через аккаунт Google.';

  @override
  String get auLinked =>
      'Аккаунт привязан. Теперь вы можете совершать покупки.';

  @override
  String get auEmail => 'Создать аккаунт с почтой';

  @override
  String get auEmailSub =>
      'Любая почта и пароль на ваш выбор. Восстановление на любом устройстве.';

  @override
  String get auNotNow => 'Не сейчас';

  @override
  String get auErrCredentialInUse =>
      'Эти данные уже привязаны к другому аккаунту. Попробуйте войти через них.';

  @override
  String get auErrAlreadyLinked => 'Этот аккаунт уже привязан.';

  @override
  String get auErrRequiresRecentLogin =>
      'В целях безопасности войдите заново перед привязкой.';

  @override
  String get auErrNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get auErrGeneric => 'Не удалось привязать. Попробуйте ещё раз.';

  @override
  String get sroSettingUpTitle => 'Настройка вашего аккаунта…';

  @override
  String get sroSettingUpBody =>
      'Готовим всё к вашей первой сессии. Это происходит только один раз.';

  @override
  String get sroLoadingTitle => 'Загрузка ваших прежних данных…';

  @override
  String get sroLoadingBody =>
      'Получаем вашу статистику, достижения, монеты и разблокировки из облака.';

  @override
  String get sroRestoringTitle => 'Восстановление прогресса…';

  @override
  String get sroRestoringBody =>
      'Применяем всё на этом устройстве. Не закрывайте приложение.';

  @override
  String get sroDoneTitle => 'Готово!';

  @override
  String get sroDoneBody => 'Ваш прогресс восстановлен.';

  @override
  String get sroFailedTitle => 'Не удалось восстановить данные';

  @override
  String get sroFailedBody =>
      'Сейчас не удалось связаться с облаком. Проверьте интернет и попробуйте снова. Можно продолжить без восстановления — мы повторим попытку при следующем запуске.';

  @override
  String get sroTryAgain => 'Повторить';

  @override
  String get sroContinueAnyway => 'Продолжить всё равно';

  @override
  String get ssiOfflinePending =>
      'Офлайн - изменения синхронизируются при подключении';

  @override
  String get ssiSyncing => 'Синхронизация...';

  @override
  String get ssiAllSynced => 'Все данные синхронизированы';

  @override
  String ssiFailedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента не синхронизировалось',
      many: '$count элементов не синхронизировались',
      few: '$count элемента не синхронизировались',
      one: '$count элемент не синхронизировался',
    );
    return '$_temp0';
  }

  @override
  String ssiPendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента ждёт синхронизации',
      many: '$count элементов ждут синхронизации',
      few: '$count элемента ждут синхронизации',
      one: '$count элемент ждёт синхронизации',
    );
    return '$_temp0';
  }

  @override
  String get ssiOffline => 'Офлайн';

  @override
  String get rvoContinue => 'ПРОДОЛЖИТЬ?';

  @override
  String get rvoSubtitlePro => 'Возродитесь и сохраните счёт · Бесплатно с Pro';

  @override
  String rvoSubtitleTimer(Object seconds) {
    return 'Возродитесь и сохраните счёт · $seconds с';
  }

  @override
  String get rvoGetLifePro => 'Получить жизнь · Бесплатно для Pro';

  @override
  String get rvoWatchAd => 'Смотреть рекламу и возродиться';

  @override
  String rvoUseCoins(Object coins) {
    return 'Потратить $coins монет';
  }

  @override
  String get rvoNoThanks => 'Нет, спасибо';

  @override
  String get tbTimesUp => 'ВРЕМЯ ВЫШЛО!';

  @override
  String tbKeepGoing(Object seconds) {
    return 'Продолжить · $seconds с';
  }

  @override
  String tbWatchAd(Object seconds) {
    return 'Смотреть рекламу — +$seconds с';
  }

  @override
  String get tbEndRun => 'Завершить забег';

  @override
  String get dbTitle => 'Ежедневный бонус';

  @override
  String get dbClaimToday => 'Заберите свою ежедневную награду!';

  @override
  String get dbComeBack => 'Возвращайтесь завтра!';

  @override
  String dbDayChip(Object day) {
    return 'Д$day';
  }

  @override
  String get dbTodaysReward => 'Награда за сегодня';

  @override
  String get dbAlreadyClaimed => 'Сегодня уже получено';

  @override
  String get dbClaim => 'ЗАБРАТЬ НАГРАДУ';

  @override
  String get dbClaim2x => 'ЗАБРАТЬ 2× — СМОТРЕТЬ РЕКЛАМУ';

  @override
  String get npPrimerTitle => 'Не пропустите!';

  @override
  String get npPrimerBody =>
      'Мы шлём лишь пару уведомлений в день — напоминание о ежедневном вызове и особые события.\n\nБез спама, обещаем. 🐍';

  @override
  String get npMaybeLater => 'Может, позже';

  @override
  String get npAllSet => '🎉 Всё готово!';

  @override
  String get npTurnOn => 'Включить';

  @override
  String get npSoftTitle => 'Хотите быть в курсе?';

  @override
  String get npSoftBody =>
      'Включите уведомления, и мы напомним о ежедневных вызовах и сериях — а ещё о важном: БЕСПЛАТНЫХ раздачах Premium и особых событиях.\n\nВсего пара в день, без спама. 🐍';

  @override
  String get npNotNow => 'Не сейчас';

  @override
  String get npEnable => 'Включить уведомления';

  @override
  String get aroUnlocked => 'ДОСТИЖЕНИЕ ОТКРЫТО';

  @override
  String get aroTapToContinue => 'Нажмите, чтобы продолжить';

  @override
  String get aroSkip => 'ПРОПУСТИТЬ';

  @override
  String aroSkipCount(Object count) {
    return 'ПРОПУСТИТЬ ($count)';
  }

  @override
  String get luLevelUp => 'НОВЫЙ УРОВЕНЬ!';

  @override
  String luReached(Object level) {
    return 'Вы достигли уровня $level';
  }

  @override
  String get luNice => 'КЛАСС';

  @override
  String get cfTapContinue => 'Нажмите в любом месте, чтобы продолжить';

  @override
  String get cfTapSkip => 'Нажмите в любом месте, чтобы пропустить';

  @override
  String ppgLvShort(Object level) {
    return 'Ур. $level';
  }

  @override
  String ppgLvUpper(Object level) {
    return 'УР. $level';
  }

  @override
  String ppgLevel(Object level) {
    return 'Уровень $level';
  }

  @override
  String get xgTitle => 'Выйти из игры?';

  @override
  String get xgBody =>
      'Вы уверены, что хотите выйти? Текущий прогресс будет потерян.';

  @override
  String get xgExit => 'Выйти';

  @override
  String get ccTitle => 'Как вы хотите играть?';

  @override
  String get ccBody =>
      'Выберите вариант — его можно сменить в Настройках → Управление.';

  @override
  String get ccSwipe => 'Свайпы';

  @override
  String get ccSwipeSub => 'Свайпайте в любом месте поля для поворота.';

  @override
  String get ccDpad => 'Кнопки D-Pad';

  @override
  String get ccDpadSub => 'Экранные кнопки направлений.';

  @override
  String rcCoinsAdded(Object coins) {
    return '🎉 +$coins монет добавлено в ваш кошелёк!';
  }

  @override
  String rcWatchAd(Object coins) {
    return 'Смотреть рекламу — +$coins монет';
  }

  @override
  String get rcNoAd => 'Сейчас нет доступной рекламы';

  @override
  String get raOptIn => 'По желанию — смотрите и зарабатывайте';

  @override
  String get compassSemantics => 'Индикатор направления свайпа';

  @override
  String homeBonusDoubled(Object coins) {
    return '🎉 Ежедневный бонус удвоен — +$coins бонусных монет!';
  }

  @override
  String get nsNewNotification => 'У вас новое уведомление';

  @override
  String get nsAchievementUnlocked => '🏆 Достижение открыто!';

  @override
  String get nsDailyReminderTitle => '🐍 Пора сыграть в Snake Classic!';

  @override
  String get nsDailyReminderBody =>
      'Выполните ежедневный вызов и поднимитесь в таблице лидеров!';

  @override
  String get mpErrMatchmaking => 'Подбор матча не удался. Попробуйте ещё раз.';

  @override
  String get mpErrCreateFailed => 'Не удалось создать игру';

  @override
  String get mpErrJoinFailed =>
      'Не удалось присоединиться. Игра заполнена или не существует.';

  @override
  String get mpErrReadyFailed => 'Не удалось обновить статус готовности';

  @override
  String get mpErrStartFailed => 'Не удалось начать игру';

  @override
  String get mpErrStartTimeout =>
      'Время запуска игры истекло. Попробуйте ещё раз.';

  @override
  String get mpErrReconnectFailed => 'Не удалось переподключиться к матчу.';

  @override
  String get mpErrConnectionLost =>
      'Связь потеряна — матч не удалось возобновить.';

  @override
  String get mpErrMatchEndedAway => 'Матч завершился, пока вас не было.';

  @override
  String get mpErrWaitingReady => 'Ожидание готовности всех игроков';

  @override
  String get mpErrOnlyHost => 'Только хост может начать игру';

  @override
  String get mpErrSessionExpired =>
      'Игровая сессия истекла. Создайте новую игру';

  @override
  String get mpErrAlreadyStarted => 'Эта игра уже началась';

  @override
  String get mpErrNeedTwoPlayers => 'Для матча нужно ровно 2 игрока';

  @override
  String get mpErrSignIn => 'Войдите, чтобы играть в мультиплеер';

  @override
  String get mpErrReconnectExpired => 'Время переподключения истекло';

  @override
  String get mpErrCheckInternet => 'Связь потеряна. Проверьте интернет';

  @override
  String get mpErrUnableJoin =>
      'Не удалось войти в комнату. Попробуйте ещё раз';

  @override
  String get mpErrGeneric => 'Что-то пошло не так. Попробуйте ещё раз';

  @override
  String stDurSeconds(Object s) {
    return '$s с';
  }

  @override
  String stDurMinutes(Object m) {
    return '$m мин';
  }

  @override
  String stDurHours(Object h) {
    return '$h ч';
  }

  @override
  String stDurMinSec(Object m, Object s) {
    return '$m мин $s с';
  }

  @override
  String stDurHourMin(Object h, Object m) {
    return '$h ч $m мин';
  }

  @override
  String dchProgressSummary(Object completed, Object total) {
    return 'Выполнено $completed из $total вызовов';
  }

  @override
  String wqProgressSummary(Object completed, Object total) {
    return '$completed / $total выполнено';
  }

  @override
  String wqClaimable(Object count) {
    return '$count можно забрать';
  }

  @override
  String wqClaimToast(Object coins, Object xp) {
    return '+$coins монет, +$xp опыта пропуска';
  }

  @override
  String get insPoints10 => '10 очков';

  @override
  String get insPoints25 => '25 очков';

  @override
  String get insPoints50 => '50 очков + новый уровень';

  @override
  String get unRules =>
      '• 3–20 символов\n• Должно начинаться с буквы\n• Только буквы, цифры и подчёркивания';

  @override
  String get dcTitleScoreEasy => 'Счёт новичка';

  @override
  String get dcTitleScoreMedium => 'Умелый игрок';

  @override
  String get dcTitleScoreHard => 'Мастер очков';

  @override
  String get dcTitleFoodEasy => 'Голодная змейка';

  @override
  String get dcTitleFoodMedium => 'Режим пира';

  @override
  String get dcTitleFoodHard => 'Ненасытный';

  @override
  String get dcTitleSurvivalEasy => 'Выживший';

  @override
  String get dcTitleSurvivalMedium => 'Выносливость';

  @override
  String get dcTitleSurvivalHard => 'Бессмертный';

  @override
  String get dcTitleGamesEasy => 'Казуальный игрок';

  @override
  String get dcTitleGamesMedium => 'Преданный';

  @override
  String get dcTitleGamesHard => 'Зависимый от змейки';

  @override
  String get dcTitleModeEasy => 'Любитель классики';

  @override
  String get dcTitleModeMedium => 'Мастер дзена';

  @override
  String get dcTitleModeHard => 'Демон скорости';

  @override
  String dcDescScore(Object target) {
    return 'Наберите не менее $target очков за одну игру';
  }

  @override
  String dcDescFood(Object target) {
    return 'Съешьте сегодня $target единиц еды';
  }

  @override
  String dcDescSurvival(Object target) {
    return 'Продержитесь $target секунд за одну игру';
  }

  @override
  String dcDescGames(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Сыграйте сегодня $target игры',
      many: 'Сыграйте сегодня $target игр',
      few: 'Сыграйте сегодня $target игры',
      one: 'Сыграйте сегодня $target игру',
    );
    return '$_temp0';
  }

  @override
  String dcDescMode(num target, Object mode) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Сыграйте $target игры в режиме «$mode»',
      many: 'Сыграйте $target игр в режиме «$mode»',
      few: 'Сыграйте $target игры в режиме «$mode»',
      one: 'Сыграйте $target игру в режиме «$mode»',
    );
    return '$_temp0';
  }

  @override
  String get wqTitleScoreEasy => 'Недельная разминка';

  @override
  String get wqTitleScoreMedium => 'Острые рефлексы';

  @override
  String get wqTitleScoreHard => 'Чемпион очков';

  @override
  String get wqTitleFoodEasy => 'Недельный перекус';

  @override
  String get wqTitleFoodMedium => 'Прожорливый';

  @override
  String get wqTitleFoodHard => 'Бездонный';

  @override
  String get wqTitleGamesEasy => 'Пять за неделю';

  @override
  String get wqTitleGamesMedium => 'Дело привычки';

  @override
  String get wqTitleGamesHard => 'Марафонец';

  @override
  String get wqTitleSurvivalEasy => 'Двухминутный заплыв';

  @override
  String get wqTitleSurvivalMedium => 'Пятиминутный заплыв';

  @override
  String get wqTitleSurvivalHard => 'Десятиминутный заплыв';

  @override
  String get wqTitleTournament => 'Завсегдатай турниров';

  @override
  String get wqTitleDailyEasy => 'Ежедневный исполнитель';

  @override
  String get wqTitleDailyMedium => 'Ежедневный знаток';

  @override
  String wqDescScore(Object target) {
    return 'Наберите $target за одну игру';
  }

  @override
  String wqDescFood(Object target) {
    return 'Съешьте $target единиц еды за неделю';
  }

  @override
  String wqDescGames(Object target) {
    return 'Сыграйте $target игр за неделю';
  }

  @override
  String wqDescSurvival(Object target) {
    return 'Продержитесь $target с за одну игру';
  }

  @override
  String wqDescTournament(num target) {
    String _temp0 = intl.Intl.pluralLogic(
      target,
      locale: localeName,
      other: 'Сыграйте $target турнирной игры',
      many: 'Сыграйте $target турнирных игр',
      few: 'Сыграйте $target турнирные игры',
      one: 'Сыграйте $target турнирную игру',
    );
    return '$_temp0';
  }

  @override
  String wqDescDaily(Object target) {
    return 'Выполните $target ежедневных вызовов за неделю';
  }

  @override
  String tnNameDaily(Object date) {
    return 'Ежедневный вызов - $date';
  }

  @override
  String tnNameWeekly(Object week) {
    return 'Еженедельный чемпионат - неделя $week';
  }

  @override
  String tnNameMonthly(Object monthYear) {
    return 'Месячное Гран-при - $monthYear';
  }

  @override
  String get tnDescDaily =>
      'Сразитесь за лучший счёт в сегодняшнем 24-часовом вызове! Лучшие получают монеты и славу.';

  @override
  String get tnDescWeekly =>
      'Главная битва недели! Соревнуйтесь с сильнейшими за крупные награды.';

  @override
  String get tnDescMonthly =>
      'Крупнейший турнир месяца! Докажите, что вы — истинный мастер «Змейки».';

  @override
  String tnRewardRank(Object rank) {
    return 'Место $rank';
  }

  @override
  String tnRewardCoinDesc(Object rank) {
    return 'Награда монетами за место $rank';
  }

  @override
  String get achTitleScore1500 => 'Разгон';

  @override
  String get achDescScore1500 => 'Наберите 1 500 очков за одну игру';

  @override
  String get achTitleScore3000 => 'В ударе';

  @override
  String get achDescScore3000 => 'Наберите 3 000 очков за одну игру';

  @override
  String get achTitleScore7500 => 'Неумолимый';

  @override
  String get achDescScore7500 => 'Наберите 7 500 очков за одну игру';

  @override
  String get achTitleScore15000 => 'Верховный охотник';

  @override
  String get achDescScore15000 => 'Наберите 15 000 очков за одну игру';

  @override
  String get achTitleScore35000 => 'Машинный разум';

  @override
  String get achDescScore35000 => 'Наберите 35 000 очков за одну игру';

  @override
  String get achTitleScore75000 => 'За гранью смертного';

  @override
  String get achDescScore75000 => 'Наберите 75 000 очков за одну игру';

  @override
  String get achTitleScore250000 => 'Четверть миллиона';

  @override
  String get achDescScore250000 => 'Наберите 250 000 очков за одну игру';

  @override
  String get achTitleBeyondTime => 'Вне времени';

  @override
  String get achDescBeyondTime => 'Продержитесь 45 минут за одну игру';

  @override
  String get achTitleHourbound => 'Целый час';

  @override
  String get achDescHourbound => 'Продержитесь целый час за одну игру';

  @override
  String get achTitleSnakeDevotee => 'Преданный змейке';

  @override
  String get achDescSnakeDevotee => 'Сыграйте 2 500 игр';

  @override
  String get achTitleTenThousandClub => 'Клуб десяти тысяч';

  @override
  String get achDescTenThousandClub => 'Сыграйте 10 000 игр';

  @override
  String get achTitleZenVeteran => 'Ветеран дзена';

  @override
  String get achDescZenVeteran => 'Завершите 100 игр в режиме «Дзен»';

  @override
  String get achTitleSpeedVeteran => 'Ветеран скорости';

  @override
  String get achDescSpeedVeteran => 'Завершите 100 игр «Скоростного вызова»';

  @override
  String get achTitleMultifoodVeteran => 'Ветеран «Мультиеды»';

  @override
  String get achDescMultifoodVeteran => 'Завершите 100 игр «Мультиеды»';

  @override
  String get achTitleTimeattackVeteran => 'Ветеран режима «На время»';

  @override
  String get achDescTimeattackVeteran => 'Завершите 100 игр «На время»';

  @override
  String get achTitleSurvivalVeteran => 'Ветеран выживания';

  @override
  String get achDescSurvivalVeteran => 'Завершите 100 игр «Выживания»';

  @override
  String get achTitlePumInitiate => 'Новичок безумия';

  @override
  String get achDescPumInitiate => 'Завершите 10 игр «Безумия усилений»';

  @override
  String get achTitlePumVeteran => 'Ветеран безумия';

  @override
  String get achDescPumVeteran => 'Завершите 100 игр «Безумия усилений»';

  @override
  String get achTitlePerfectInitiate => 'Пурист';

  @override
  String get achDescPerfectInitiate => 'Завершите 10 «Идеальных игр»';

  @override
  String get achTitlePerfectVeteran => 'Дисциплина';

  @override
  String get achDescPerfectVeteran => 'Завершите 100 «Идеальных игр»';

  @override
  String get achTitleZen10000 => 'Дзен через край';

  @override
  String get achDescZen10000 => 'Наберите 10 000 в режиме «Дзен»';

  @override
  String get achTitleSpeed5000 => 'Размытие';

  @override
  String get achDescSpeed5000 => 'Наберите 5 000 в «Скоростном вызове»';

  @override
  String get achTitleMultifood10000 => 'Бесконечный буфет';

  @override
  String get achDescMultifood10000 => 'Наберите 10 000 в «Мультиеде»';

  @override
  String get achTitleTimeattack5000 => 'Гонка с часами';

  @override
  String get achDescTimeattack5000 => 'Наберите 5 000 в режиме «На время»';

  @override
  String get achTitlePum2000 => 'Полный заряд';

  @override
  String get achDescPum2000 => 'Наберите 2 000 в «Безумии усилений»';

  @override
  String get achTitlePerfect1000 => 'Безупречный забег';

  @override
  String get achDescPerfect1000 => 'Наберите 1 000 в «Идеальной игре»';

  @override
  String get achTitleComboSingularity => 'Сингулярность комбо';

  @override
  String get achDescComboSingularity => 'Сделайте комбо 200x за одну игру';

  @override
  String get achTitleWorldSerpent => 'Мировой змей';

  @override
  String get achDescWorldSerpent => 'Вырастите змейку до длины 750';

  @override
  String get achTitleLightspeed => 'Скорость света';

  @override
  String get achDescLightspeed =>
      'Достигните 30-го игрового уровня за одну игру';

  @override
  String get achTitlePowerOverwhelming => 'Сокрушительная мощь';

  @override
  String get achDescPowerOverwhelming => 'Соберите 5 000 усилений за всё время';

  @override
  String get achTitleGreedIsGood => 'Жадность — это хорошо';

  @override
  String get achDescGreedIsGood => 'Соберите 25 усилений «Множитель очков»';

  @override
  String get achTitleTimeBender => 'Повелитель замедления';

  @override
  String get achDescTimeBender => 'Соберите 25 усилений «Замедление»';

  @override
  String get achTitleGastronome => 'Гастроном';

  @override
  String get achDescGastronome => 'Съешьте 100 000 единиц еды за всё время';

  @override
  String get achTitleLivingLegend => 'Живая легенда';

  @override
  String get achDescLivingLegend => 'Накопите 50 000 000 очков за всё время';

  @override
  String get achTitlePerpetualMotion => 'Вечный двигатель';

  @override
  String get achDescPerpetualMotion => 'Серия из 50 игр (каждая 30 с+)';

  @override
  String get achTitleImmaculate => 'Безукоризненный';

  @override
  String get achDescImmaculate => 'Завершите 100 идеальных игр';

  @override
  String get achTitleFortnightFaithful => 'Верный две недели';

  @override
  String get achDescFortnightFaithful => 'Играйте 14 дней подряд';

  @override
  String get achTitleSteadySnake => 'Стойкая змейка';

  @override
  String get achDescSteadySnake => 'Продержитесь 30+ секунд в 100 играх';

  @override
  String get achTitleMarathonMonth => 'Дух марафона';

  @override
  String get achDescMarathonMonth => 'Продержитесь 30+ секунд в 1 000 играх';

  @override
  String get achTitleLunchtimeLegend => 'Легенда обеда';

  @override
  String get achDescLunchtimeLegend => 'Завершите игру между полуднем и 14:00';

  @override
  String get legalNoticePrefix => 'Играя, вы принимаете наши ';

  @override
  String get legalNoticeAnd => ' и ';

  @override
  String get dayOneReminderTitle => 'Змейка скучает по тебе 🐍';

  @override
  String dayOneReminderBodyScore(int score) {
    return 'Твой рекорд — $score. Сможешь побить?';
  }

  @override
  String get dayOneReminderBodyNoScore =>
      'Быстрая партия? Твой первый рекорд ждёт.';

  @override
  String get goTomorrowLabel => 'ВОЗВРАЩАЙСЯ ЗАВТРА';

  @override
  String goTomorrowReward(int coins, int day) {
    return 'Забери $coins монет в день $day твоей серии';
  }

  @override
  String get rvAteFoodUnknown => '🍎 Съел еду';

  @override
  String get rvCollectedPowerUpUnknown => '⚡ Подобрал усиление';

  @override
  String get boardTall => 'Высокое';

  @override
  String get boardTallDesc =>
      'Заполняет экран телефона — больше места для манёвра';

  @override
  String get boardTallPlus => 'Высокое плюс';

  @override
  String get boardTallPlusDesc => 'Арена побольше в формате телефона';

  @override
  String get mpErrReadyTimeout =>
      'Игроки не успели подтвердить готовность. Ищем новый матч…';

  @override
  String mpLobbyReadyDeadline(int seconds) {
    return 'Готовность · $secondsс';
  }

  @override
  String get mpLobbyWaitingOpponentReady => 'Ждём готовности соперника…';

  @override
  String get gameDirectionalPad => 'Крестовина';

  @override
  String get gameGoHome => 'На главный экран';

  @override
  String get gamePauseGame => 'Пауза';

  @override
  String get gameResumeGame => 'Продолжить';

  @override
  String get gameLeaveMatch => 'Покинуть матч';

  @override
  String get gameSteerUp => 'Повернуть вверх';

  @override
  String get gameSteerDown => 'Повернуть вниз';

  @override
  String get gameSteerLeft => 'Повернуть влево';

  @override
  String get gameSteerRight => 'Повернуть вправо';

  @override
  String get mpTurnBlocked => 'Заблокировано';

  @override
  String get insHudPause => 'Кнопка паузы';

  @override
  String get insHudPauseDesc => 'Пауза и продолжение — вверху справа';

  @override
  String get insDpad => 'Экранная крестовина';

  @override
  String get insDpadDesc => 'Кнопки для поворотов вместо свайпов';

  @override
  String get insControlsNote =>
      'Включить крестовину и выбрать её расположение можно в настройках управления.';

  @override
  String get insVersus => 'Версус';

  @override
  String get insVersusOnline => 'Онлайн 1 на 1';

  @override
  String get insVersusOnlineDesc =>
      'Классические правила, две змейки, одно поле, в реальном времени';

  @override
  String get insVersusQuick => 'Быстрый матч';

  @override
  String get insVersusQuickDesc => 'Автоматически находит соперника';

  @override
  String get insVersusRoom => 'Приватная комната';

  @override
  String get insVersusRoomDesc =>
      'Создайте комнату и поделитесь кодом или присоединитесь к другу';

  @override
  String get homeVersusCta => 'ВЕРСУС';

  @override
  String get homeVersusSubtitle => '1 на 1, классика · Быстрый матч или друг';

  @override
  String get hwVersusTitle => 'Сыграйте с кем-то';

  @override
  String get hwVersusMsg =>
      'Версус — это онлайн 1 на 1 по классическим правилам. Быстрый матч найдёт соперника, или создайте приватную комнату.';

  @override
  String get hwHelpTitle => 'Что-то ещё?';

  @override
  String get hwHelpMsg =>
      'Здесь описаны правила, управление и режим Версус. Настройки — рядом.';

  @override
  String get insOnPhone => 'На телефоне';

  @override
  String get insOnKeyboard => 'На клавиатуре';
}
