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
  String get mpLobbyNoPlayersFound => 'ИГРОКИ НЕ НАЙДЕНЫ';

  @override
  String get mpLobbyNoPlayersBody =>
      'К сожалению, соперников не нашлось.\nПопробуйте ещё раз или создайте свою комнату!';

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
}
