# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" for Play Console / App Store Connect. Written for
**8.0.3+84** (2026-11-22; 8.0.0+81 was refused by Play over a Wi-Fi feature flag, 8.0.1+82 and 8.0.2+83 were superseded by banner fixes; same notes). The 7.7.x builds were never uploaded, so this text
covers everything since the live 7.6.x: the 7.7.3 notes (archived in
release_notes_7.7.3.md) plus the 8.0 work below.

What 8.0.0 adds over 7.7.3:

- **Every theme redesigned** (feature/theme-scenes): each of the 11 themes has
  its own painted scene behind the menus and the board, baked once into a GPU
  image so all of them hold 60 fps on the A24.
- **Smoother gameplay** (HCPP, googleads-mobile-flutter#1551): animated banner
  ads no longer drop the game to ~43 fps. No snake flicker at bends; new turn
  chevrons; eating shows the food going in.
- **Redesigned pause screen** with a run card; Restart asks before scrapping
  the run.
- Ads (not in the notes): banners stay the classic anchored adaptive size
  (the large banner was tried and dropped in 8.0.3); a hung warm banner can
  no longer blank every banner; Meta, Mintegral and InMobi mediation adapters (idle until their accounts are
  live).
- **iOS:** needs a macOS build for the new adapters; see CLAUDE.md, "macOS
  session".

Every Play block fits the 500-character limit. Mode names are each
language's in-app name (modeZen in the .arb files); Turkish is not an in-app
language. **Never name or allude to the big game release the Miami Nights
theme nods to.**

---

## Play Console — paste as-is

es-419 and es-ES share the `es` text.

```
<en-US>
A fresh coat of paint.

• All 11 themes redesigned with painted scenes, plus a new limited theme, Miami Nights: free until Dec 7.
• Smoother gameplay: a steady 60 fps, no more flicker, new turn and eating animations.
• Redesigned pause screen. Restart now asks before ending your run.
• Daily challenges count toward weekly quests and pay out automatically.
• Closing the app on game over keeps your score and coins.
• Zen Mode no longer shows a wall glow.
</en-US>
<ar>
حلة جديدة بالكامل.

• إعادة تصميم كل الثيمات الـ11 بمشاهد مرسومة، وثيم جديد لفترة محدودة، ليالي ميامي: مجاني حتى 7 ديسمبر.
• لعب أكثر سلاسة: 60 إطارًا ثابتة، بلا وميض، وحركات جديدة للالتفاف والأكل.
• شاشة إيقاف مؤقت جديدة. إعادة البدء تسأل قبل إنهاء جولتك.
• التحديات اليومية تُحتسب ضمن المهام الأسبوعية وتُضاف مكافآتها تلقائيًا.
• إغلاق التطبيق عند انتهاء اللعبة يحفظ نقاطك وعملاتك.
• لم يعد وضع الاسترخاء يُظهر توهج الجدران.
</ar>
<es-419>
Una mano de pintura nueva.

• Los 11 temas, rediseñados con escenas pintadas, y un tema por tiempo limitado, Noches de Miami: gratis hasta el 7 de dic.
• Juego más fluido: 60 fps estables, sin parpadeos, nuevas animaciones al girar y comer.
• Nueva pantalla de pausa. Reiniciar ahora pide confirmación.
• Los desafíos diarios cuentan para las misiones semanales y se cobran solos.
• Cerrar la app al perder conserva tu puntuación y monedas.
• El Modo Zen ya no muestra el brillo de pared.
</es-419>
<es-ES>
Una mano de pintura nueva.

• Los 11 temas, rediseñados con escenas pintadas, y un tema por tiempo limitado, Noches de Miami: gratis hasta el 7 de dic.
• Juego más fluido: 60 fps estables, sin parpadeos, nuevas animaciones al girar y comer.
• Nueva pantalla de pausa. Reiniciar ahora pide confirmación.
• Los desafíos diarios cuentan para las misiones semanales y se cobran solos.
• Cerrar la app al perder conserva tu puntuación y monedas.
• El Modo Zen ya no muestra el brillo de pared.
</es-ES>
<fr-FR>
Un vrai coup de neuf.

• Les 11 thèmes redessinés avec des décors peints, et un thème limité, Nuits de Miami : gratuit jusqu'au 7 déc.
• Jeu plus fluide : 60 fps stables, plus de scintillement, nouvelles animations de virage et de repas.
• Nouvel écran de pause. Recommencer demande confirmation.
• Les défis du jour comptent pour les quêtes hebdo et sont récompensés tout seuls.
• Fermer l'app en fin de partie garde score et pièces.
• Le Mode Zen n'affiche plus la lueur des murs.
</fr-FR>
<hi-IN>
बिल्कुल नया रूप।

• सभी 11 थीम नए पेंटेड दृश्यों के साथ, और नई लिमिटेड थीम मियामी नाइट्स: 7 दिसंबर तक मुफ़्त।
• और स्मूद गेमप्ले: लगातार 60 fps, कोई झिलमिलाहट नहीं, मुड़ने और खाने के नए एनिमेशन।
• नई पॉज़ स्क्रीन। रीस्टार्ट अब राउंड खत्म करने से पहले पूछता है।
• डेली चैलेंज वीकली क्वेस्ट में गिने जाते हैं और इनाम अपने-आप मिलते हैं।
• गेम ओवर पर ऐप बंद करने से स्कोर और सिक्के नहीं खोते।
• ज़ेन मोड में अब दीवार की चमक नहीं दिखती।
</hi-IN>
<it-IT>
Una mano di vernice nuova.

• Tutti gli 11 temi ridisegnati con scenari dipinti, più un tema a tempo, Notti di Miami: gratis fino al 7 dic.
• Gioco più fluido: 60 fps stabili, niente sfarfallio, nuove animazioni di svolta e pasto.
• Nuova schermata di pausa. Ricomincia ora chiede conferma.
• Le sfide giornaliere contano per le missioni settimanali e si riscattano da sole.
• Chiudere l'app a fine partita mantiene punteggio e monete.
• La Modalità Zen non mostra più il bagliore dei muri.
</it-IT>
<pl-PL>
Zupełnie nowa odsłona.

• Wszystkie 11 motywów z nowymi malowanymi scenami i motyw na krótko, Noce Miami: za darmo do 7 grudnia.
• Płynniejsza gra: stałe 60 fps, bez migotania, nowe animacje skrętu i jedzenia.
• Nowy ekran pauzy. Restart pyta przed zakończeniem rundy.
• Wyzwania dzienne liczą się do zadań tygodniowych i same się odbierają.
• Zamknięcie aplikacji po przegranej zachowuje wynik i monety.
• Tryb Zen nie pokazuje już poświaty ścian.
</pl-PL>
<pt-BR>
Cara nova.

• Os 11 temas redesenhados com cenários pintados, e um tema por tempo limitado, Noites de Miami: grátis até 7 de dez.
• Jogo mais fluido: 60 fps estáveis, sem tremulação, novas animações de curva e de comer.
• Nova tela de pausa. Reiniciar agora pede confirmação.
• Desafios diários contam para as missões semanais e são resgatados sozinhos.
• Fechar o app no fim de jogo mantém pontuação e moedas.
• O Modo Zen não mostra mais o brilho das paredes.
</pt-BR>
<ru-RU>
Совершенно новый вид.

• Все 11 тем перерисованы с новыми сценами, и временная тема «Ночи Майами»: бесплатно до 7 декабря.
• Плавнее игра: стабильные 60 fps, без мерцания, новые анимации поворота и еды.
• Новый экран паузы. «Заново» теперь спрашивает подтверждение.
• Задания дня засчитываются в недельные квесты и начисляются сами.
• Закрытие приложения после проигрыша сохраняет счёт и монеты.
• В режиме «Дзен» больше нет подсветки стен.
</ru-RU>
<tr-TR>
Baştan sona yenilendi.

• 11 temanın tamamı yeni boyalı sahnelerle yenilendi; sınırlı süreli yeni tema Miami Geceleri 7 Aralık'a kadar ücretsiz.
• Daha akıcı oyun: sabit 60 fps, titreme yok, yeni dönüş ve yeme animasyonları.
• Yeni duraklatma ekranı. Yeniden başlat artık önce soruyor.
• Günlük görevler haftalık görevlere sayılıyor ve ödüller otomatik geliyor.
• Oyun sonunda uygulamayı kapatmak skoru ve jetonları korur.
• Zen Modu artık duvar parıltısı göstermiyor.
</tr-TR>
```

## App Store Connect — What's New (8.0.1)

Entered in App Store Connect on 2026-11-21. The App Store already had 7.7.0
live (submitted 2026-11-18 with the Miami Nights IAP, both approved), so the iOS text keeps
only the 8.0 lines; Miami Nights is mentioned as "still free until Dec 7".
Promotional Text is unchanged (carried over from 7.7.0).

**en-US / en-GB**
```
Snake Classic 8.0: a fresh coat of paint.

• All 11 themes redesigned with painted scenes. Miami Nights is still free until Dec 7.
• Smoother gameplay: a steady 60 fps, no more flicker, new turn and eating animations.
• Redesigned pause screen. Restart now asks before ending your run.
```

**ar**
```
Snake Classic 8.0: حلة جديدة بالكامل.

• إعادة تصميم كل الثيمات الـ11 بمشاهد مرسومة. ثيم ليالي ميامي لا يزال مجانيًا حتى 7 ديسمبر.
• لعب أكثر سلاسة: 60 إطارًا ثابتة، بلا وميض، وحركات جديدة للالتفاف والأكل.
• شاشة إيقاف مؤقت جديدة. إعادة البدء تسأل قبل إنهاء جولتك.
```

**es-MX**
```
Snake Classic 8.0: una mano de pintura nueva.

• Los 11 temas, rediseñados con escenas pintadas. Noches de Miami sigue gratis hasta el 7 de dic.
• Juego más fluido: 60 fps estables, sin parpadeos, nuevas animaciones al girar y comer.
• Nueva pantalla de pausa. Reiniciar ahora pide confirmación antes de terminar tu partida.
```

**fr-FR**
```
Snake Classic 8.0 : un vrai coup de neuf.

• Les 11 thèmes redessinés avec des décors peints. Nuits de Miami reste gratuit jusqu'au 7 déc.
• Jeu plus fluide : 60 fps stables, plus de scintillement, nouvelles animations de virage et de repas.
• Nouvel écran de pause. Recommencer demande confirmation avant de mettre fin à la partie.
```

**hi**
```
Snake Classic 8.0: बिल्कुल नया रूप।

• सभी 11 थीम नए पेंटेड दृश्यों के साथ। मियामी नाइट्स अब भी 7 दिसंबर तक मुफ़्त है।
• और स्मूद गेमप्ले: लगातार 60 fps, कोई झिलमिलाहट नहीं, मुड़ने और खाने के नए एनिमेशन।
• नई पॉज़ स्क्रीन। रीस्टार्ट अब राउंड खत्म करने से पहले पूछता है।
```

**it**
```
Snake Classic 8.0: una mano di vernice nuova.

• Tutti gli 11 temi ridisegnati con scenari dipinti. Notti di Miami resta gratis fino al 7 dic.
• Gioco più fluido: 60 fps stabili, niente sfarfallio, nuove animazioni di svolta e pasto.
• Nuova schermata di pausa. Ricomincia ora chiede conferma prima di chiudere la partita.
```

**pl**
```
Snake Classic 8.0: zupełnie nowa odsłona.

• Wszystkie 11 motywów z nowymi malowanymi scenami. Noce Miami wciąż za darmo do 7 grudnia.
• Płynniejsza gra: stałe 60 fps, bez migotania, nowe animacje skrętu i jedzenia.
• Nowy ekran pauzy. Restart pyta przed zakończeniem rundy.
```

**pt-BR**
```
Snake Classic 8.0: cara nova.

• Os 11 temas redesenhados com cenários pintados. Noites de Miami continua grátis até 7 de dez.
• Jogo mais fluido: 60 fps estáveis, sem tremulação, novas animações de curva e de comer.
• Nova tela de pausa. Reiniciar agora pede confirmação antes de encerrar a partida.
```

**tr**
```
Snake Classic 8.0: baştan sona yenilendi.

• 11 temanın tamamı yeni boyalı sahnelerle yenilendi. Miami Geceleri 7 Aralık'a kadar hâlâ ücretsiz.
• Daha akıcı oyun: sabit 60 fps, titreme yok, yeni dönüş ve yeme animasyonları.
• Yeni duraklatma ekranı. Yeniden başlat artık turu bitirmeden önce soruyor.
```
