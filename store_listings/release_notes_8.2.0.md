# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" for Play Console / App Store Connect. Written for
**8.2.0+88** (2026-11-26), the Versus reliability release. 8.1.0+87 is the
previous release; its notes are archived in release_notes_8.1.0.md.

What 8.2.0 adds over 8.1.0 (found in a two-device Versus test against
production on 2026-11-26):

- **Versus lobby:** the READY countdown stops once everyone is ready (it used
  to kill rooms the host was about to start); a separate 40 s "host never
  started" limit with its own message; a match-found race that could leave a
  phone on the Versus screen while seated in a room.
- **Result screen** always appears (the winner sometimes got none); Back
  after a match re-shows it instead of offering to forfeit; LIVE → FINAL,
  "Match over." instead of live taunts; per-outcome footer.
- **Connection drops:** RECONNECTING overlay at once, faster reconnect
  attempts, and "The match ended while you were away" instead of a frozen
  board.
- **Forced update on Android too** (dashboard minimum version, 8.2.0+ only).
- **Versus analytics:** versus_lobby_closed, versus_connection,
  versus_match_quality (CLAUDE.md, "Versus analytics (8.2)").
- No backend change required (backend master is compatible as deployed).

Every Play block fits the 500-character limit.

---

## Play Console — Release notes (paste as-is)

```
<en-US>
Smoother Versus matches.

• Matches no longer fall apart when both players are ready and waiting for the host.
• You always see your result at the end of a match.
• If your connection drops, the game tells you it's reconnecting and gets you back faster.
• Clearer messages when a match can't start.
</en-US>
<ar>
مباريات تحدٍّ أكثر سلاسة.

• لم تعد المباريات تُلغى عندما يكون اللاعبان جاهزين بانتظار المضيف.
• سترى نتيجتك دائمًا في نهاية كل مباراة.
• إذا انقطع اتصالك، تخبرك اللعبة بأنها تعيد الاتصال وتعيدك أسرع.
• رسائل أوضح عندما لا تبدأ المباراة.
</ar>
<es-419>
Partidas Versus más fluidas.

• Las partidas ya no se cancelan cuando ambos están listos esperando al anfitrión.
• Siempre verás tu resultado al terminar una partida.
• Si se corta tu conexión, el juego te avisa que se está reconectando y te devuelve más rápido.
• Mensajes más claros cuando una partida no puede empezar.
</es-419>
<es-ES>
Partidas Versus más fluidas.

• Las partidas ya no se cancelan cuando ambos están listos esperando al anfitrión.
• Siempre verás tu resultado al terminar una partida.
• Si se corta tu conexión, el juego te avisa de que se está reconectando y te devuelve antes.
• Mensajes más claros cuando una partida no puede empezar.
</es-ES>
<fr-FR>
Des matchs Versus plus fluides.

• Les matchs ne s'annulent plus quand les deux joueurs sont prêts et attendent l'hôte.
• Tu vois toujours ton résultat à la fin d'un match.
• Si ta connexion coupe, le jeu indique qu'il se reconnecte et te ramène plus vite.
• Des messages plus clairs quand un match ne peut pas démarrer.
</fr-FR>
<hi-IN>
वर्सस मैच अब और बेहतर।

• दोनों खिलाड़ी तैयार हों और होस्ट का इंतज़ार कर रहे हों, तो मैच अब रद्द नहीं होता।
• मैच के अंत में आपको हमेशा अपना नतीजा दिखेगा।
• कनेक्शन टूटे तो गेम बताता है कि वह फिर से जुड़ रहा है और आपको जल्दी वापस लाता है।
• मैच शुरू न हो पाने पर साफ़ संदेश।
</hi-IN>
<it-IT>
Partite Versus più fluide.

• Le partite non saltano più quando entrambi sono pronti e aspettano l'host.
• Vedi sempre il tuo risultato alla fine di una partita.
• Se la connessione cade, il gioco ti dice che si sta riconnettendo e ti riporta dentro prima.
• Messaggi più chiari quando una partita non può iniziare.
</it-IT>
<pl-PL>
Płynniejsze mecze Versus.

• Mecze nie przepadają już, gdy obaj gracze są gotowi i czekają na gospodarza.
• Zawsze zobaczysz swój wynik na koniec meczu.
• Gdy połączenie zerwie się, gra pokaże, że łączy się ponownie, i szybciej cię przywróci.
• Jaśniejsze komunikaty, gdy mecz nie może się zacząć.
</pl-PL>
<pt-BR>
Partidas Versus mais fluidas.

• As partidas não caem mais quando os dois estão prontos esperando o anfitrião.
• Você sempre vê seu resultado no fim da partida.
• Se a conexão cair, o jogo avisa que está reconectando e te traz de volta mais rápido.
• Mensagens mais claras quando uma partida não consegue começar.
</pt-BR>
<ru-RU>
Матчи Versus стали стабильнее.

• Матч больше не срывается, когда оба игрока готовы и ждут хоста.
• В конце матча вы всегда видите результат.
• Если связь пропала, игра покажет, что переподключается, и вернёт вас быстрее.
• Понятные сообщения, если матч не может начаться.
</ru-RU>
<tr-TR>
Daha akıcı Versus maçları.

• İki oyuncu hazır olup ev sahibini beklerken maçlar artık iptal olmuyor.
• Maç sonunda sonucunu her zaman görüyorsun.
• Bağlantın koparsa oyun yeniden bağlandığını söylüyor ve seni daha hızlı geri getiriyor.
• Maç başlayamadığında daha net mesajlar.
</tr-TR>
```
