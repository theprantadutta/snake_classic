# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" for Play Console / App Store Connect. Written for
**7.7.1+78** (2026-11-19: 7.7.0+77 plus the UI audit fixes, tablet landscape, brightness and 60 Hz work; the App Store Connect version created as 7.6.2 must be renamed to 7.7.1 before the build is attached). The 7.6.0 notes are archived in release_notes_7.6.0.md.

7.6.1+75 was built for Play on 2026-11-16 but 7.7.0 supersedes it on both
stores (it includes everything 7.6.1 has). What 7.7.0 adds over 7.6.0:

- **Daily challenges count toward weekly quests** (34dc93f). The Daily Doer /
  Daily Adept weekly quests had no progress source, so they never moved.
- **No wall glow in Zen** (34dc93f). Zen has no walls (the snake wraps).
  Both from Marthad Osman's Play review, promised "for our next update".
- **iOS: Settings > Rate Snake Classic works.** `openStoreListing()` was
  called without the App Store ID, which iOS needs, so the row did nothing.
  The automatic review prompt on iOS now asks after 5 games / 1 day instead
  of 8 / 3 (the listing had zero ratings).
- **Daily challenges claim themselves** (c7d75cc). 1,715 players completed
  one in Oct 21 - Nov 17, only 351 ever claimed; claims expire daily.
- **Home Season tile shows waiting rewards** (c7d75cc). 1,335 of 1,396
  tier-2+ players had never claimed one.
- **A run is kept when the app closes on game over** (f2f1884). Since the
  continue window, closing the app within 8 s lost the score, coins and stats.
- Android only, invisible: Play's "fix your payment" in-app message
  (7ec2f00) and the edge-to-edge fix for Play's warning (e48b236).
- **Miami Nights theme**: free for everyone until Dec 7 2026 (inclusive),
  then Pro-only. A generic sunset-neon theme for the Nov 19 big game
  release week. Never name or allude to that game anywhere (notes,
  listing, pushes): it's someone else's trademark.

Play's text is 7.6.1's plus the theme and three reward/run lines (its rate
button already worked); Play drops the intro line and the auto-claim
line's second half to fit. The App Store text adds the rate-button line
too. Mode names are each language's in-app name (modeZen in the .arb
files); Turkish is not an in-app language. Every Play block fits the
500-character limit.

---

## Play Console — paste as-is

es-419 and es-ES share the `es` text.

```
<en-US>
• New limited theme, Miami Nights: sunset neon, free for everyone until Dec 7.
• Completing daily challenges now counts toward your weekly quests.
• Zen Mode no longer shows a wall warning glow, since Zen has no walls.
• Completed daily challenges now pay out automatically.
• The Season tile on Home lights up when you have rewards to claim.
• Closing the app on the game-over screen no longer loses that run's score and coins.
</en-US>
<ar>
• ثيم جديد لفترة محدودة، ليالي ميامي: نيون الغروب، مجاني للجميع حتى 7 ديسمبر.
• إكمال التحديات اليومية يُحتسب الآن ضمن مهامك الأسبوعية.
• لم يعد وضع الاسترخاء يُظهر توهج التحذير من الجدران، فلا جدران فيه.
• مكافآت التحديات اليومية المكتملة تُضاف الآن تلقائيًا.
• تضيء بطاقة «الموسم» في الشاشة الرئيسية عندما تكون لديك مكافآت لاستلامها.
• إغلاق التطبيق في شاشة انتهاء اللعبة لم يعد يُضيّع نقاط تلك الجولة وعملاتها.
</ar>
<es-419>
• Nuevo tema por tiempo limitado, Noches de Miami: neón de atardecer, gratis hasta el 7 de dic.
• Completar desafíos diarios ahora cuenta para tus misiones semanales.
• El Modo Zen ya no muestra el brillo de advertencia de pared, porque no tiene paredes.
• Los desafíos diarios completados ahora se cobran solos.
• La casilla Temporada del inicio se ilumina cuando tienes recompensas por reclamar.
• Cerrar la app en la pantalla de fin de partida ya no hace perder la puntuación ni las monedas.
</es-419>
<es-ES>
• Nuevo tema por tiempo limitado, Noches de Miami: neón de atardecer, gratis hasta el 7 de dic.
• Completar desafíos diarios ahora cuenta para tus misiones semanales.
• El Modo Zen ya no muestra el brillo de advertencia de pared, porque no tiene paredes.
• Los desafíos diarios completados ahora se cobran solos.
• La casilla Temporada del inicio se ilumina cuando tienes recompensas por reclamar.
• Cerrar la app en la pantalla de fin de partida ya no hace perder la puntuación ni las monedas.
</es-ES>
<fr-FR>
• Nouveau thème limité, Nuits de Miami : néons du couchant, gratuit jusqu'au 7 déc.
• Terminer des défis quotidiens compte désormais pour vos quêtes hebdomadaires.
• Le Mode Zen n'affiche plus la lueur d'alerte des murs, puisqu'il n'a pas de murs.
• Les défis du jour terminés sont désormais récompensés automatiquement.
• La tuile Saison de l'accueil s'allume quand des récompenses vous attendent.
• Fermer l'app sur l'écran de fin de partie ne fait plus perdre le score ni les pièces.
</fr-FR>
<hi-IN>
• नई लिमिटेड थीम, मियामी नाइट्स: सूर्यास्त का नियॉन, 7 दिसंबर तक सबके लिए मुफ़्त।
• डेली चैलेंज पूरे करना अब आपकी वीकली क्वेस्ट में गिना जाता है।
• ज़ेन मोड में अब दीवार की चेतावनी वाली चमक नहीं दिखती, क्योंकि इसमें दीवारें नहीं हैं।
• पूरे हुए डेली चैलेंज के इनाम अब अपने-आप मिलते हैं।
• होम पर सीज़न टाइल अब चमकती है जब कोई इनाम लेना बाकी हो।
• गेम ओवर स्क्रीन पर ऐप बंद करने से अब उस राउंड का स्कोर और सिक्के नहीं खोते।
</hi-IN>
<it-IT>
• Nuovo tema a tempo, Notti di Miami: neon al tramonto, gratis per tutti fino al 7 dic.
• Completare le sfide giornaliere ora conta per le missioni settimanali.
• La Modalità Zen non mostra più il bagliore di avviso dei muri, perché non ha muri.
• Le sfide giornaliere completate ora vengono riscattate da sole.
• Il riquadro Stagione nella Home si illumina quando hai premi da riscattare.
• Chiudere l'app nella schermata di fine partita non fa più perdere punteggio e monete.
</it-IT>
<pl-PL>
• Nowy motyw na krótko, Noce Miami: neon zachodu, za darmo dla wszystkich do 7 grudnia.
• Ukończone wyzwania dzienne liczą się teraz do zadań tygodniowych.
• Tryb Zen nie pokazuje już ostrzegawczej poświaty ścian, bo nie ma w nim ścian.
• Nagrody za ukończone wyzwania dzienne trafiają teraz do Ciebie automatycznie.
• Kafelek Sezon na ekranie głównym świeci, gdy czekają nagrody do odebrania.
• Zamknięcie aplikacji na ekranie końca gry nie kasuje już wyniku i monet z tej rundy.
</pl-PL>
<pt-BR>
• Novo tema por tempo limitado, Noites de Miami: neon do pôr do sol, grátis até 7 de dez.
• Completar desafios diários agora conta para as suas missões semanais.
• O Modo Zen não mostra mais o brilho de alerta das paredes, já que não tem paredes.
• Desafios diários concluídos agora são resgatados sozinhos.
• O bloco Temporada na tela inicial acende quando há recompensas para resgatar.
• Fechar o app na tela de fim de jogo não faz mais perder a pontuação e as moedas.
</pt-BR>
<ru-RU>
• Новая временная тема «Ночи Майами»: неон заката, бесплатно для всех до 7 декабря.
• Выполненные ежедневные задания теперь засчитываются в еженедельные квесты.
• В режиме «Дзен» больше нет подсветки-предупреждения о стенах: стен там нет.
• Награды за выполненные задания дня теперь начисляются сами.
• Плитка «Сезон» на главном экране подсвечивается, когда вас ждут награды.
• Закрытие приложения на экране конца игры больше не стирает счёт и монеты этого забега.
</ru-RU>
<tr-TR>
• Sınırlı süreli yeni tema, Miami Geceleri: gün batımı neonu, 7 Aralık'a kadar herkese ücretsiz.
• Tamamladığın günlük görevler artık haftalık görevlerine sayılıyor.
• Zen Modu artık duvar uyarı parıltısı göstermiyor, çünkü Zen'de duvar yok.
• Tamamlanan günlük görevlerin ödülleri artık otomatik veriliyor.
• Ana ekrandaki Sezon kutucuğu, alınacak ödül olduğunda parlıyor.
• Oyun sonu ekranında uygulamayı kapatmak artık o turun skorunu ve jetonlarını kaybettirmiyor.
</tr-TR>
```

## App Store Connect — What's New (7.7.1)

The App Store has 7.6.0 live, so this carries the 7.6.1 fixes too. The rate
line uses each language's in-app row name (settingsRateApp). Promotional
Text is unchanged; see release_notes_7.6.0.md.

**en-US / en-GB**
```
Fixes from your feedback.

• New limited theme, Miami Nights: sunset neon, free for everyone until Dec 7.
• Completing daily challenges now counts toward your weekly quests.
• Zen Mode no longer shows a wall warning glow, since Zen has no walls.
• Completed daily challenges now pay out automatically, so rewards no longer expire unclaimed.
• The Season tile on Home lights up when you have rewards to claim.
• Closing the app on the game-over screen no longer loses that run's score and coins.
• "Rate Snake Classic" in Settings now opens the App Store.
```

**ar**
```
إصلاحات بناءً على ملاحظاتكم.

• ثيم جديد لفترة محدودة، ليالي ميامي: نيون الغروب، مجاني للجميع حتى 7 ديسمبر.
• إكمال التحديات اليومية يُحتسب الآن ضمن مهامك الأسبوعية.
• لم يعد وضع الاسترخاء يُظهر توهج التحذير من الجدران، فلا جدران فيه.
• مكافآت التحديات اليومية المكتملة تُضاف الآن تلقائيًا، فلا تضيع قبل استلامها.
• تضيء بطاقة «الموسم» في الشاشة الرئيسية عندما تكون لديك مكافآت لاستلامها.
• إغلاق التطبيق في شاشة انتهاء اللعبة لم يعد يُضيّع نقاط تلك الجولة وعملاتها.
• زر «قيّم Snake Classic» في الإعدادات يفتح الآن App Store.
```

**es-MX**
```
Arreglos gracias a tus comentarios.

• Nuevo tema por tiempo limitado, Noches de Miami: neón de atardecer, gratis hasta el 7 de dic.
• Completar desafíos diarios ahora cuenta para tus misiones semanales.
• El Modo Zen ya no muestra el brillo de advertencia de pared, porque no tiene paredes.
• Los desafíos diarios completados ahora se cobran solos: las recompensas ya no caducan sin reclamar.
• La casilla Temporada del inicio se ilumina cuando tienes recompensas por reclamar.
• Cerrar la app en la pantalla de fin de partida ya no hace perder la puntuación ni las monedas.
• «Valora Snake Classic» en Ajustes ahora abre el App Store.
```

**fr-FR**
```
Des corrections grâce à vos retours.

• Nouveau thème limité, Nuits de Miami : néons du couchant, gratuit jusqu'au 7 déc.
• Terminer des défis quotidiens compte désormais pour vos quêtes hebdomadaires.
• Le Mode Zen n'affiche plus la lueur d'alerte des murs, puisqu'il n'a pas de murs.
• Les défis du jour terminés sont désormais récompensés automatiquement : plus de récompenses perdues.
• La tuile Saison de l'accueil s'allume quand des récompenses vous attendent.
• Fermer l'app sur l'écran de fin de partie ne fait plus perdre le score ni les pièces.
• « Noter Snake Classic » dans les Réglages ouvre désormais l'App Store.
```

**hi**
```
आपके सुझावों से सुधार।

• नई लिमिटेड थीम, मियामी नाइट्स: सूर्यास्त का नियॉन, 7 दिसंबर तक सबके लिए मुफ़्त।
• डेली चैलेंज पूरे करना अब आपकी वीकली क्वेस्ट में गिना जाता है।
• ज़ेन मोड में अब दीवार की चेतावनी वाली चमक नहीं दिखती, क्योंकि इसमें दीवारें नहीं हैं।
• पूरे हुए डेली चैलेंज के इनाम अब अपने-आप मिलते हैं, इसलिए वे बिना लिए खत्म नहीं होते।
• होम पर सीज़न टाइल अब चमकती है जब कोई इनाम लेना बाकी हो।
• गेम ओवर स्क्रीन पर ऐप बंद करने से अब उस राउंड का स्कोर और सिक्के नहीं खोते।
• सेटिंग्स में "Snake Classic को रेट करें" अब App Store खोलता है।
```

**it**
```
Correzioni grazie ai vostri commenti.

• Nuovo tema a tempo, Notti di Miami: neon al tramonto, gratis per tutti fino al 7 dic.
• Completare le sfide giornaliere ora conta per le missioni settimanali.
• La Modalità Zen non mostra più il bagliore di avviso dei muri, perché non ha muri.
• Le sfide giornaliere completate ora vengono riscattate da sole: niente più premi scaduti.
• Il riquadro Stagione nella Home si illumina quando hai premi da riscattare.
• Chiudere l'app nella schermata di fine partita non fa più perdere punteggio e monete.
• "Valuta Snake Classic" nelle Impostazioni ora apre l'App Store.
```

**pl**
```
Poprawki dzięki Waszym opiniom.

• Nowy motyw na krótko, Noce Miami: neon zachodu, za darmo dla wszystkich do 7 grudnia.
• Ukończone wyzwania dzienne liczą się teraz do zadań tygodniowych.
• Tryb Zen nie pokazuje już ostrzegawczej poświaty ścian, bo nie ma w nim ścian.
• Nagrody za ukończone wyzwania dzienne trafiają teraz do Ciebie automatycznie i już nie przepadają.
• Kafelek Sezon na ekranie głównym świeci, gdy czekają nagrody do odebrania.
• Zamknięcie aplikacji na ekranie końca gry nie kasuje już wyniku i monet z tej rundy.
• „Oceń Snake Classic” w Ustawieniach otwiera teraz App Store.
```

**pt-BR**
```
Correções a partir do seu feedback.

• Novo tema por tempo limitado, Noites de Miami: neon do pôr do sol, grátis até 7 de dez.
• Completar desafios diários agora conta para as suas missões semanais.
• O Modo Zen não mostra mais o brilho de alerta das paredes, já que não tem paredes.
• Desafios diários concluídos agora são resgatados sozinhos: as recompensas não expiram mais.
• O bloco Temporada na tela inicial acende quando há recompensas para resgatar.
• Fechar o app na tela de fim de jogo não faz mais perder a pontuação e as moedas.
• "Avalie Snake Classic" nos Ajustes agora abre a App Store.
```

**tr**
```
Geri bildirimlerinle gelen düzeltmeler.

• Sınırlı süreli yeni tema, Miami Geceleri: gün batımı neonu, 7 Aralık'a kadar herkese ücretsiz.
• Tamamladığın günlük görevler artık haftalık görevlerine sayılıyor.
• Zen Modu artık duvar uyarı parıltısı göstermiyor, çünkü Zen'de duvar yok.
• Tamamlanan günlük görevlerin ödülleri artık otomatik veriliyor, alınmadan kaybolmuyor.
• Ana ekrandaki Sezon kutucuğu, alınacak ödül olduğunda parlıyor.
• Oyun sonu ekranında uygulamayı kapatmak artık o turun skorunu ve jetonlarını kaybettirmiyor.
• Ayarlar'daki "Snake Classic'i Değerlendir" artık App Store'u açıyor.
```
