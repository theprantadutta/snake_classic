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
}
