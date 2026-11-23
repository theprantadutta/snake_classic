# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" for Play Console / App Store Connect. Written for
**8.1.0+87** (2026-11-23), the November retention release
(docs/RETENTION_PLAN_2026-11.md). 8.0.5+86 is the previous Play release; its
notes (the 8.0 redesign) are archived in release_notes_8.0.5.md.

What 8.1.0 adds over 8.0.5:

- **Daily bonus items:** day 3 a power-up, day 5 double Season XP for 24 h,
  day 7 a premium theme for a day; home pill and Season XP bar.
- **Game over NEXT UP panel** (from the 2nd game): daily challenges, Season,
  tomorrow's reward; "Remind me tomorrow" row; local day-1 reminder.
- **Coin cosmetics** (glow / neon trails, fire skin) and "watch 2 ads, wear
  it for a day"; Season rewards no longer stripped by the premium sync.
- **First three games:** steering hint, no revive / continue, no mode picker,
  no gameplay banner, no full-screen trophy reveals.
- **Play updates:** "Update now / Later" dialog, then Play's blocking update
  (no Restart button to forget).
- **More games screen** (Home menu + Settings): Cosmo Strike, Sunstone,
  Pourfect, Screw Out, Gridwell, Jadewell.
- **Needs the backend from `feature/retention-2026-11` deployed BEFORE this
  build goes live** (`POST /cosmetics/buy-with-coins`, coin catalog, daily
  reminder change).

Every Play block fits the 500-character limit. **Never name or allude to the
big game release the Miami Nights theme nods to.**

---

## Play Console — Release notes (paste as-is)

es-419 and es-ES share the `es` text.

```
<en-US>
More to play for, every day.

• The daily bonus now includes power-ups, double Season XP and a free theme for a day.
• After a game, NEXT UP shows your daily challenges and tomorrow's reward.
• Buy trails and skins with coins, or try a premium look for a day with two short ads.
• Season rewards no longer disappear after syncing.
• Updates now install in one tap.
• New More games screen with our other games.
</en-US>
<ar>
المزيد لتلعب من أجله كل يوم.

• المكافأة اليومية تشمل الآن معززات، وضعف نقاط الموسم، وثيمًا مجانيًا ليوم واحد.
• بعد كل لعبة، تعرض «التالي» تحدياتك اليومية ومكافأة الغد.
• اشترِ الذيول والأشكال بالعملات، أو جرّب مظهرًا مميزًا ليوم كامل بإعلانين قصيرين.
• مكافآت الموسم لم تعد تختفي بعد المزامنة.
• التحديثات تُثبَّت الآن بلمسة واحدة.
• شاشة جديدة «المزيد من الألعاب» بألعابنا الأخرى.
</ar>
<es-419>
Más motivos para jugar cada día.

• El bono diario ahora trae potenciadores, doble XP de Temporada y un tema gratis por un día.
• Tras cada partida, SIGUIENTE muestra tus desafíos diarios y la recompensa de mañana.
• Compra estelas y skins con monedas, o prueba un look premium por un día con dos anuncios cortos.
• Las recompensas de Temporada ya no desaparecen al sincronizar.
• Las actualizaciones se instalan con un toque.
• Nueva pantalla Más juegos con nuestros otros juegos.
</es-419>
<es-ES>
Más motivos para jugar cada día.

• El bono diario ahora trae potenciadores, doble XP de Temporada y un tema gratis por un día.
• Tras cada partida, SIGUIENTE muestra tus desafíos diarios y la recompensa de mañana.
• Compra estelas y skins con monedas, o prueba un look premium por un día con dos anuncios cortos.
• Las recompensas de Temporada ya no desaparecen al sincronizar.
• Las actualizaciones se instalan con un toque.
• Nueva pantalla Más juegos con nuestros otros juegos.
</es-ES>
<fr-FR>
Plus de raisons de jouer chaque jour.

• Le bonus du jour offre des bonus, l'XP de Saison doublée et un thème gratuit pour un jour.
• Après chaque partie, À SUIVRE montre tes défis du jour et la récompense de demain.
• Achète traînées et skins avec tes pièces, ou essaie un look premium un jour avec deux pubs courtes.
• Les récompenses de Saison ne disparaissent plus après la synchro.
• Les mises à jour s'installent en un geste.
• Nouvel écran Plus de jeux avec nos autres jeux.
</fr-FR>
<hi-IN>
हर दिन खेलने की और वजहें।

• डेली बोनस में अब पावर-अप, डबल सीज़न XP और एक दिन के लिए मुफ़्त थीम।
• हर गेम के बाद, आगे क्या में आपके डेली चैलेंज और कल का इनाम।
• सिक्कों से ट्रेल और स्किन खरीदें, या दो छोटे विज्ञापन देखकर एक दिन प्रीमियम लुक आज़माएँ।
• सिंक के बाद सीज़न इनाम अब गायब नहीं होते।
• अपडेट अब एक टैप में इंस्टॉल होते हैं।
• नई और गेम स्क्रीन, हमारे दूसरे गेम के साथ।
</hi-IN>
<it-IT>
Più motivi per giocare ogni giorno.

• Il bonus giornaliero ora include potenziamenti, XP Stagione doppia e un tema gratis per un giorno.
• Dopo ogni partita, PROSSIMI mostra le sfide giornaliere e il premio di domani.
• Compra scie e skin con le monete, o prova un look premium per un giorno con due brevi pubblicità.
• I premi Stagione non spariscono più dopo la sincronizzazione.
• Gli aggiornamenti si installano con un tocco.
• Nuova schermata Altri giochi con i nostri altri giochi.
</it-IT>
<pl-PL>
Więcej powodów, by grać codziennie.

• Bonus dzienny daje teraz ulepszenia, podwójne XP Sezonu i darmowy motyw na jeden dzień.
• Po każdej grze DALEJ pokazuje wyzwania dnia i jutrzejszą nagrodę.
• Kupuj ślady i skórki za monety albo wypróbuj wygląd premium na dzień za dwie krótkie reklamy.
• Nagrody Sezonu nie znikają już po synchronizacji.
• Aktualizacje instalują się jednym dotknięciem.
• Nowy ekran Więcej gier z naszymi innymi grami.
</pl-PL>
<pt-BR>
Mais motivos para jogar todo dia.

• O bônus diário agora traz power-ups, XP de Temporada em dobro e um tema grátis por um dia.
• Depois de cada partida, PRÓXIMOS mostra seus desafios diários e o prêmio de amanhã.
• Compre rastros e skins com moedas, ou teste um visual premium por um dia com dois anúncios curtos.
• Os prêmios de Temporada não somem mais após sincronizar.
• As atualizações agora instalam com um toque.
• Nova tela Mais jogos com nossos outros jogos.
</pt-BR>
<ru-RU>
Больше поводов играть каждый день.

• Ежедневный бонус теперь даёт усиления, двойной опыт сезона и бесплатную тему на день.
• После каждой игры блок «ДАЛЕЕ» показывает задания дня и завтрашнюю награду.
• Покупайте следы и скины за монеты или примерьте премиум-образ на день за две короткие рекламы.
• Награды сезона больше не пропадают после синхронизации.
• Обновления ставятся в одно касание.
• Новый экран «Другие игры» с нашими играми.
</ru-RU>
<tr-TR>
Her gün oynamak için daha fazla sebep.

• Günlük bonus artık güçlendirmeler, iki kat Sezon XP ve bir günlük ücretsiz tema veriyor.
• Her oyundan sonra SIRADAKİ, günlük görevlerini ve yarının ödülünü gösteriyor.
• İzleri ve görünümleri jetonla al ya da iki kısa reklamla premium bir görünümü bir gün dene.
• Sezon ödülleri artık senkronizasyondan sonra kaybolmuyor.
• Güncellemeler artık tek dokunuşla yükleniyor.
• Diğer oyunlarımızla yeni Daha fazla oyun ekranı.
</tr-TR>
```

## App Store Connect — What's New

Not written yet. The last iOS build was 8.0.1 (82); the next one is built on
macOS (see CLAUDE.md, "macOS session") and should carry 8.0.3's banner fix
plus everything above. Reuse the Play lines **without "Updates now install
in one tap"** (the Play update flow is Android-only; iOS keeps its own
App Store dialog). The 8.0.1 App Store text is in release_notes_8.0.5.md.
