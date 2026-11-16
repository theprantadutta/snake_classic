# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" and "Promotional Text" for Play Console / App Store
Connect. Written for **7.6.0+74**.

7.6.0 (like 7.5.0) is 7.4.4 rebuilt on Flutter 3.50 and the new Android tooling (Gradle
9.8.1, AGP 9.4.1, Kotlin 2.4.0). It changes nothing players see, so the
text below is the 7.4.4 text unchanged. If 7.4.4 already went live on Play,
archive these notes as release_notes_7.4.4.md and give 7.5.0 a short
"stability and performance improvements" block instead.

**The two stores get different text again.** Play has 7.4.3 live (notes
archived in release_notes_7.4.3.md), so the Play block covers only what
7.4.4 adds. The App Store last shipped 7.3.1, so its block also carries the
stability line from 7.4.x.

What 7.4.4 adds:

- **Zen and Speed daily challenges now count.** The server's challenges
  asked for "zen" / "speed" while a finished run reported "Zen Mode" /
  "Speed Challenge", so only Classic challenges ever progressed. A player
  reported it in a Play review (replied to on 2026-11-01, promising the fix
  in this update and a month of Pro).
- **A crash when music starts.** The music loops streamed from a temporary
  file Android can delete on low storage; about 96% of 7.4.3's Play
  crashes. Players see it as "the app closed on its own".

Mode names in the notes are each language's in-app names (modeZen,
modeSpeedChallenge in the .arb files). Turkish is not an in-app language,
so it gets a Turkish rendering.

Promotional Text is unchanged from 7.3.0 — still accurate, and App Store
Connect does not carry it over to a new version on its own.

Every What's New block fits Play's 500-character limit. App Store limits:
What's New 4000, Promotional Text 170.

en-GB is not listed separately: it takes the `en` text verbatim.

---

## App Store Connect — What's New (7.6.0)

The App Store has 7.4.4 live (its What's New, the 7.4.4 text, went out
with the 2026-11-04 submission and is in git history). 7.6.0 changes
nothing players see, so it gets the short stability block. Entered in App
Store Connect for all 10 locales on 2026-11-13, with the Promotional Text
below.

- **en / en-GB:** Stability and performance improvements. Snake Classic is now built on the latest tools, so it runs more smoothly and reliably.
- **ar:** تحسينات في الثبات والأداء. أصبحت Snake Classic مبنية على أحدث الأدوات، لتعمل بسلاسة وموثوقية أكبر.
- **es-MX:** Mejoras de estabilidad y rendimiento. Snake Classic ahora usa las herramientas más recientes, para funcionar de forma más fluida y confiable.
- **fr:** Améliorations de la stabilité et des performances. Snake Classic repose désormais sur les outils les plus récents, pour un jeu plus fluide et plus fiable.
- **hi:** स्थिरता और परफ़ॉर्मेंस में सुधार। Snake Classic अब नए टूल्स पर बना है, इसलिए यह ज़्यादा स्मूथ और भरोसेमंद तरीके से चलता है।
- **it:** Miglioramenti di stabilità e prestazioni. Snake Classic ora usa gli strumenti più recenti, per un gioco più fluido e affidabile.
- **pl:** Poprawki stabilności i wydajności. Snake Classic korzysta teraz z najnowszych narzędzi, więc działa płynniej i bardziej niezawodnie.
- **pt-BR:** Melhorias de estabilidade e desempenho. O Snake Classic agora usa as ferramentas mais recentes, para rodar de forma mais fluida e confiável.
- **tr:** Kararlılık ve performans iyileştirmeleri. Snake Classic artık en yeni araçlarla geliştiriliyor; böylece daha akıcı ve güvenilir çalışıyor.

---

## Play Console — paste as-is

Release → Release notes → paste this whole block. es-419 and es-ES share
the `es` text.

```
<en-US>
Fixes from your feedback.

• Zen Mode and Speed Challenge daily challenges now count the games you play in those modes.
• Fixed a crash some phones hit when the music started.
</en-US>
<ar>
إصلاحات بناءً على ملاحظاتكم.

• تحديات وضع الاسترخاء وتحدي السرعة اليومية تحتسب الآن الألعاب التي تلعبها في هذين الوضعين.
• إصلاح انهيار كان يحدث على بعض الهواتف عند بدء الموسيقى.
</ar>
<es-419>
Arreglos gracias a tus comentarios.

• Los desafíos diarios de Modo Zen y Desafío de Velocidad ahora cuentan las partidas que juegas en esos modos.
• Corregimos un cierre inesperado al empezar la música en algunos teléfonos.
</es-419>
<es-ES>
Arreglos gracias a tus comentarios.

• Los desafíos diarios de Modo Zen y Desafío de Velocidad ahora cuentan las partidas que juegas en esos modos.
• Corregimos un cierre inesperado al empezar la música en algunos teléfonos.
</es-ES>
<fr-FR>
Des corrections grâce à vos retours.

• Les défis quotidiens Mode Zen et Défi de Vitesse comptent désormais les parties jouées dans ces modes.
• Correction d'un plantage au lancement de la musique sur certains téléphones.
</fr-FR>
<hi-IN>
आपके सुझावों से सुधार।

• ज़ेन मोड और स्पीड चैलेंज के डेली चैलेंज अब उन मोड में खेले गए गेम गिनते हैं।
• कुछ फ़ोन पर म्यूज़िक शुरू होते समय होने वाला क्रैश ठीक किया गया।
</hi-IN>
<it-IT>
Correzioni grazie ai vostri commenti.

• Le sfide giornaliere di Modalità Zen e Sfida di Velocità ora contano le partite giocate in quelle modalità.
• Corretto un arresto anomalo all'avvio della musica su alcuni telefoni.
</it-IT>
<pl-PL>
Poprawki dzięki Waszym opiniom.

• Codzienne wyzwania Tryb Zen i Wyzwanie prędkości liczą teraz gry rozegrane w tych trybach.
• Naprawiono awarię przy włączaniu muzyki na niektórych telefonach.
</pl-PL>
<pt-BR>
Correções a partir do seu feedback.

• Os desafios diários de Modo Zen e Desafio de Velocidade agora contam as partidas jogadas nesses modos.
• Corrigimos um fechamento inesperado ao iniciar a música em alguns celulares.
</pt-BR>
<ru-RU>
Исправления по вашим отзывам.

• Ежедневные задания режимов «Дзен» и «Скоростной вызов» теперь засчитывают игры в этих режимах.
• Исправлен вылет при запуске музыки на некоторых телефонах.
</ru-RU>
<tr-TR>
Geri bildirimlerinle gelen düzeltmeler.

• Zen Modu ve Hız Mücadelesi günlük görevleri artık bu modlarda oynadığın oyunları sayıyor.
• Bazı telefonlarda müzik başlarken yaşanan çökme düzeltildi.
</tr-TR>
```

---

## Promotional Text (App Store, unchanged from 7.3.0)

- **en / en-GB:** A brand-new pixel-grid look, one more go from game over, every run charted, and smoother online duels.
- **ar:** مظهر جديد بشبكة البكسلات، وفرصة أخرى عند انتهاء اللعبة، ورسم بياني لكل جولة، ومواجهات أونلاين أكثر سلاسة.
- **es:** Un aspecto nuevo de cuadrícula de píxeles, una oportunidad más al perder, cada partida en un gráfico y duelos online más fluidos.
- **fr:** Un tout nouveau look en grille de pixels, une chance de plus en fin de partie, chaque partie en graphique et des duels en ligne plus fluides.
- **hi:** बिल्कुल नया पिक्सेल-ग्रिड रूप, गेम ओवर से एक और मौक़ा, हर रन का चार्ट और ज़्यादा स्मूथ ऑनलाइन मुक़ाबले।
- **it:** Un nuovo aspetto a griglia di pixel, un'altra possibilità a fine partita, ogni partita in un grafico e sfide online più fluide.
- **pl:** Nowy wygląd w siatce pikseli, jeszcze jedna szansa po końcu gry, każda gra na wykresie i płynniejsze pojedynki online.
- **pt:** Um visual novo em grade de pixels, mais uma chance no fim de jogo, cada partida num gráfico e duelos online mais fluidos.
- **ru:** Новый облик в пиксельной сетке, ещё один шанс после проигрыша, график каждого забега и более плавные онлайн-дуэли.
- **tr:** Yepyeni piksel ızgarası görünümü, oyun sonunda bir şans daha, her oyunun grafiği ve daha akıcı çevrimiçi düellolar.
