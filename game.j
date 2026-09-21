// --- ESTADO GLOBAL E PERSISTÊNCIA ---
let GameData = {
    coins: 100,
    wins: 0,
    losses: 0,
    activeCreatureIndex: 2, // Começa com Voltrak por padrão (conforme a imagem)
    creatures: [
        { name: "Igniscore", type: "Fogo", emoji: "🔥", evoEmoji: "🐲", lvl: 1, xp: 0, maxXp: 100, hp: 100, maxHp: 100, atk: 22, def: 8, ability: "Chama Rápida" },
        { name: "Aquaflow", type: "Água", emoji: "💧", evoEmoji: "🌊", lvl: 1, xp: 0, maxXp: 100, hp: 115, maxHp: 115, atk: 18, def: 11, ability: "Jato Líquido" },
        { name: "Voltrak", type: "Energia", emoji: "⚡", evoEmoji: "⚡👑", lvl: 1, xp: 0, maxXp: 100, hp: 90, maxHp: 90, atk: 26, def: 6, ability: "Pulso Eletro" }
    ],
    enemy: { name: "Bug Selvagem", emoji: "🐛", hp: 80, maxHp: 80, atk: 15, def: 4 }
};

// Funções de Load/Save LocalStorage
function saveGame() {
    localStorage.setItem('digital_battle_save', JSON.stringify(GameData));
}

function loadGame() {
    const saved = localStorage.getItem('digital_battle_save');
    if (saved) {
        try {
            GameData = JSON.parse(saved);
        } catch (e) {
            console.error("Erro ao carregar save:", e);
        }
    }
}

// Inicialização ao carregar a página
window.onload = function() {
    loadGame();
    updateUI();
};

function updateUI() {
    // Atualizar moedas na loja
    const coinEl = document.getElementById('shop-coins');
    if (coinEl) coinEl.innerText = GameData.coins;
    
    renderCreaturesList();
}

// Alternar entre ecrãs (Menus)
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(s => s.style.display = 'none');
    const target = document.getElementById(screenId);
    if (target) {
        target.style.display = 'flex';
        if (screenId === 'screen-creatures') renderCreaturesList();
        if (screenId === 'screen-shop') updateUI();
    }
}

// Renderizar lista de criaturas na tela de gestão
function renderCreaturesList() {
    const container = document.getElementById('creatures-list-container');
    if (!container) return;
    container.innerHTML = '';

    GameData.creatures.forEach((c, index) => {
        const isActive = index === GameData.activeCreatureIndex;
        const card = document.createElement('div');
        card.style.background = 'rgba(15, 23, 42, 0.9)';
        card.style.border = isActive ? '2px solid #38bdf8' : '2px solid #1e293b';
        card.style.borderRadius = '12px';
        card.style.padding = '12px 15px';
        card.style.marginBottom = '10px';
        card.style.display = 'flex';
        card.style.alignItems = 'center';
        card.style.cursor = 'pointer';
        card.style.width = '100%';
        card.style.maxWidth = '340px';

        let avatarIcon = c.lvl >= 5 ? c.evoEmoji : c.emoji;

        card.innerHTML = `
            <div style="font-size: 2.2rem; margin-right: 15px;">${avatarIcon}</div>
            <div style="text-align: left; flex-grow: 1;">
                <div style="font-weight: bold; color: #38bdf8; font-size: 1rem;">
                    ${c.name} ${isActive ? '⭐ (Ativa)' : ''}
                </div>
                <div style="font-size: 0.75rem; color: #94a3b8;">
                    Nv. ${c.lvl} | HP: ${c.hp}/${c.maxHp} | XP: ${c.xp}/${c.maxXp}
                </div>
                <div style="font-size: 0.75rem; color: #38bdf8; margin-top: 2px;">
                    ATK: ${c.atk} | DEF: ${c.def}
                </div>
            </div>
        `;

        card.onclick = () => {
            GameData.activeCreatureIndex = index;
            saveGame();
            updateUI();
            alert(`${c.name} selecionada como combatente principal!`);
        };

        container.appendChild(card);
    });
}

// --- SISTEMA DE LOJA ---
function buyItem(type) {
    const activeC = GameData.creatures[GameData.activeCreatureIndex];

    if (type === 'heal') {
        if (GameData.coins < 30) { alert("DATA insuficiente!"); return; }
        GameData.coins -= 30;
        activeC.hp = activeC.maxHp;
        alert("HP restaurado a 100%!");
    } else if (type === 'energy') {
        if (GameData.coins < 20) { alert("DATA insuficiente!"); return; }
        GameData.coins -= 20;
        alert("Energia de combate recarregada!");
    } else if (type === 'xp') {
        if (GameData.coins < 50) { alert("DATA insuficiente!"); return; }
        GameData.coins -= 50;
        addXpToActive(50);
        alert("Boost de +50 XP aplicado!");
    }

    saveGame();
    updateUI();
}

// --- SISTEMA DE EVOLUÇÃO E XP ---
function addXpToActive(amount) {
    const c = GameData.creatures[GameData.activeCreatureIndex];
    c.xp += amount;
    
    // Verificar se sobe de nível
    while (c.xp >= c.maxXp) {
        c.xp -= c.maxXp;
        c.lvl++;
        c.maxXp = Math.floor(c.maxXp * 1.3);
        c.maxHp += 20;
        c.hp = c.maxHp;
        c.atk += 6;
        c.def += 3;

        alert(`🎉 LEVEL UP! ${c.name} subiu para o Nv. ${c.lvl}!\nAtributos melhorados!`);

        // Evento de Digivolução no Nível 5
        if (c.lvl === 5) {
            alert(`✨ EVOLUÇÃO DESBLOQUEADA!\nA sua criatura evoluiu para uma forma superior (${c.evoEmoji})!`);
        }
    }
}

// --- SISTEMA DE BATALHA POR TURNOS ---
function startBattle() {
    const c = GameData.creatures[GameData.activeCreatureIndex];
    if (c.hp <= 0) {
        alert("A sua criatura está sem HP! Visite a Loja para recuperar a vida.");
        return;
    }

    // Gerar inimigo com base no nível da criatura
    const enemyTypes = [
        { name: "Bug Selvagem", emoji: "🐛", hpBase: 70, atkBase: 14 },
        { name: "Glitch Corrompido", emoji: "👾", hpBase: 95, atkBase: 18 },
        { name: "Malware Sentinela", emoji: "🤖", hpBase: 120, atkBase: 23 }
    ];
    const template = enemyTypes[Math.floor(Math.random() * enemyTypes.length)];
    
    GameData.enemy = {
        name: template.name,
        emoji: template.emoji,
        hp: template.hpBase + (c.lvl * 8),
        maxHp: template.hpBase + (c.lvl * 8),
        atk: template.atkBase + (c.lvl * 3),
        def: 3 + Math.floor(c.lvl / 2)
    };

    showScreen('screen-battle');
    updateBattleUI();
    logBattle(`Início do combate contra ${GameData.enemy.name}!`);
}

function updateBattleUI() {
    const c = GameData.creatures[GameData.activeCreatureIndex];
    const enemy = GameData.enemy;

    // Jogador
    document.getElementById('battle-player-name').innerText = `${c.name} (Nv. ${c.lvl})`;
    document.getElementById('battle-player-hp').innerText = `HP: ${c.hp}/${c.maxHp}`;
    document.getElementById('battle-player-avatar').innerText = c.lvl >= 5 ? c.evoEmoji : c.emoji;
    const pBar = document.getElementById('battle-player-hp-bar');
    if (pBar) pBar.style.width = `${Math.max(0, (c.hp / c.maxHp) * 100)}%`;

    // Inimigo
    document.getElementById('battle-enemy-name').innerText = enemy.name;
    document.getElementById('battle-enemy-hp').innerText = `HP: ${enemy.hp}/${enemy.maxHp}`;
    document.getElementById('battle-enemy-avatar').innerText = enemy.emoji;
    const eBar = document.getElementById('battle-enemy-hp-bar');
    if (eBar) eBar.style.width = `${Math.max(0, (enemy.hp / enemy.maxHp) * 100)}%`;
}

function logBattle(text) {
    const logBox = document.getElementById('battle-log');
    if (!logBox) return;
    logBox.innerHTML += `<div>> ${text}</div>`;
    logBox.scrollTop = logBox.scrollHeight;
}

function playerAttack() {
    const c = GameData.creatures[GameData.activeCreatureIndex];
    const enemy = GameData.enemy;

    // Calcular dano do jogador
    let dmgToEnemy = Math.max(5, c.atk - enemy.def + Math.floor(Math.random() * 6));
    enemy.hp = Math.max(0, enemy.hp - dmgToEnemy);
    logBattle(`${c.name} usou ataque e causou ${dmgToEnemy} de dano!`);

    updateBattleUI();

    if (enemy.hp <= 0) {
        endBattle(true);
        return;
    }

    // Turno do Inimigo após breve pausa lógica
    setTimeout(() => {
        let dmgToPlayer = Math.max(3, enemy.atk - c.def + Math.floor(Math.random() * 4));
        c.hp = Math.max(0, c.hp - dmgToPlayer);
        logBattle(`${enemy.name} contra-atacou e causou ${dmgToPlayer} de dano!`);
        updateBattleUI();

        if (c.hp <= 0) {
            endBattle(false);
        }
    }, 600);
}

function playerSpecial() {
    const c = GameData.creatures[GameData.activeCreatureIndex];
    const enemy = GameData.enemy;

    let dmgToEnemy = Math.max(12, Math.floor(c.atk * 1.6) - enemy.def);
    enemy.hp = Math.max(0, enemy.hp - dmgToEnemy);
    logBattle(`⚡ HABILIDADE ESPECIAL (${c.ability})! Causou ${dmgToEnemy} de dano crítico!`);

    updateBattleUI();

    if (enemy.hp <= 0) {
        endBattle(true);
        return;
    }

    setTimeout(() => {
        let dmgToPlayer = Math.max(3, enemy.atk - c.def);
        c.hp = Math.max(0, c.hp - dmgToPlayer);
        logBattle(`${enemy.name} atacou e causou ${dmgToPlayer} de dano.`);
        updateBattleUI();

        if (c.hp <= 0) {
            endBattle(false);
        }
    }, 600);
}

function endBattle(won) {
    const c = GameData.creatures[GameData.activeCreatureIndex];
    if (won) {
        GameData.wins++;
        let rewardCoins = 45 + (c.lvl * 5);
        let rewardXp = 40 + (c.lvl * 10);
        GameData.coins += rewardCoins;
        
        logBattle(`🎉 VITÓRIA! Recebeu +${rewardCoins} DATA e +${rewardXp} XP.`);
        alert(`Vitória gloriosa!\nRecompensas: +${rewardCoins} DATA | +${rewardXp} XP`);
        
        addXpToActive(rewardXp);
    } else {
        GameData.losses++;
        logBattle(`❌ DERROTA... A sua criatura foi derrotada.`);
        alert("A sua criatura desmaiou em combate! Visite a Loja para a curar.");
    }

    saveGame();
    setTimeout(() => {
        showScreen('screen-main');
    }, 1200);
}
// --- NOVAS CRIATURAS E ELEMENTOS ---
// Certifique-se de adicionar as novas criaturas ao array existente se desejar:
// { name: "Frostbite", type: "Gelo", emoji: "❄️", evoEmoji: "🧊👑", lvl: 1, xp: 0, maxXp: 100, hp: 105, maxHp: 105, atk: 22, def: 14, ability: "Corte Glacial" },
// { name: "Metallix", type: "Metal", emoji: "⚙️", evoEmoji: "🛡️", lvl: 1, xp: 0, maxXp: 100, hp: 140, maxHp: 140, atk: 20, def: 18, emoji: "⚙️", ability: "Impacto de Aço" }

// --- SISTEMA DE MISSÕES / FASES ---
const missionsData = [
    { floor: 1, name: "Firewall Inicial", enemyName: "Malware Sentinela", enemyEmoji: "🤖", hp: 100, atk: 15, def: 4, rewardData: 40, rewardXp: 50 },
    { floor: 2, name: "Corredor Cryptado", enemyName: "Bug Espião", enemyEmoji: "🐛", hp: 130, atk: 20, def: 6, rewardData: 70, rewardXp: 80 },
    { floor: 3, name: "Núcleo Corrompido", enemyName: "Trojan Alpha", enemyEmoji: "👾", hp: 170, atk: 25, def: 9, rewardData: 110, rewardXp: 120 },
    { floor: 4, name: "Acesso de Elite", enemyName: "Ransomware Boss", emoji: "💀", hp: 220, atk: 32, def: 12, rewardData: 180, rewardXp: 200 }
];

function renderMissionsList() {
    const container = document.getElementById('mission-list');
    if (!container) return;
    container.innerHTML = '';

    missionsData.forEach((m) => {
        const card = document.createElement('div');
        card.style.background = 'rgba(15, 23, 42, 0.9)';
        card.style.border = '2px solid #1e293b';
        card.style.borderRadius = '12px';
        card.style.padding = '12px 15px';
        card.style.marginBottom = '10px';
        card.style.display = 'flex';
        card.style.justifyContent = 'space-between';
        card.style.alignItems = 'center';
        card.style.width = '100%';
        card.style.maxWidth = '340px';

        card.innerHTML = `
            <div style="text-align: left;">
                <div style="font-weight: bold; color: #38bdf8; font-size: 0.95rem;">Andar ${m.floor}: ${m.name}</div>
                <div style="font-size: 0.75rem; color: #94a3b8;">Inimigo: ${m.enemyName} ${m.enemyEmoji || '👾'}</div>
                <div style="font-size: 0.75rem; color: #10b981;">Recompensa: +${m.rewardData} DATA</div>
            </div>
            <button onclick="startMission(${m.floor})" style="padding: 8px 12px; background: #0284c7; border: none; border-radius: 6px; color: white; font-weight: bold; cursor: pointer;">Lutar</button>
        `;
        container.appendChild(card);
    });
}

function startMission(floorNum) {
    const mission = missionsData.find(m => m.floor === floorNum);
    if (!mission) return;

    const c = GameData.creatures[GameData.activeCreatureIndex];
    if (c.hp <= 0) {
        alert("A sua criatura está sem HP! Visite a Loja para a curar.");
        return;
    }

    GameData.enemy = {
        name: mission.enemyName,
        emoji: mission.enemyEmoji || '👾',
        hp: mission.hp,
        maxHp: mission.hp,
        atk: mission.atk,
        def: mission.def,
        rewardData: mission.rewardData,
        rewardXp: mission.rewardXp
    };

    showScreen('screen-battle');
    updateBattleUI();
    logBattle(`Missão Andar ${mission.floor} iniciada contra ${mission.enemyName}!`);
}
// --- ESTRUTURAS DE DADOS ADICIONAIS ---
// Garanta que o seu GameData inicializado tem: 
// achievements: [{id: 1, title: "Primeira Vitória", desc: "Vença 1 batalha", target: 1, progress: 0, reward: 50, claimed: false}],
// stats: { battlesWon: 0, floorsCleared: 0, gachaRolls: 0, timePlayedMin: 0 },
// lastActiveTime: Date.now()

// --- 1. SISTEMA DE CONQUISTAS ---
const achievementsData = [
    { id: 'win_1', title: "Iniciante Digital", desc: "Vença 1 batalha", target: 1, current: 0, reward: 40, claimed: false },
    { id: 'floor_2', title: "Aventureiro de Redes", desc: "Conquiste o Andar 2", target: 2, current: 0, reward: 80, claimed: false },
    { id: 'gacha_1', title: "Caçador de Raridades", desc: "Faça 1 Invocação Gacha", target: 1, current: 0, reward: 60, claimed: false }
];

function renderAchievements() {
    const container = document.getElementById('achievements-list');
    if (!container) return;
    container.innerHTML = '';

    achievementsData.forEach(ach => {
        const card = document.createElement('div');
        card.style.cssText = "background: rgba(15, 23, 42, 0.9); border: 2px solid #1e293b; border-radius: 12px; padding: 12px; margin-bottom: 10px; width: 100%; max-width: 320px; text-align: left;";
        
        card.innerHTML = `
            <div style="font-weight: bold; color: #facc15; font-size: 0.95rem;">${ach.title}</div>
            <div style="font-size: 0.75rem; color: #94a3b8; margin: 4px 0;">${ach.desc}</div>
            <div style="font-size: 0.75rem; color: #38bdf8;">Progresso: ${ach.current}/${ach.target}</div>
            <button onclick="claimAchievement('${ach.id}')" style="margin-top: 8px; width: 100%; padding: 6px; background: ${ach.claimed ? '#334155' : '#10b981'}; border: none; border-radius: 6px; color: white; font-weight: bold; cursor: pointer;" ${ach.claimed ? 'disabled' : ''}>
                ${ach.claimed ? 'Resgatado' : `Reclamar +${ach.reward} DATA`}
            </button>
        `;
        container.appendChild(card);
    });
}

function claimAchievement(id) {
    const ach = achievementsData.find(a => a.id === id);
    if (ach && ach.current >= ach.target && !ach.claimed) {
        ach.claimed = true;
        GameData.dataCurrency = (GameData.dataCurrency || 100) + ach.reward;
        saveGameData();
        renderAchievements();
        alert(`Parabéns! Ganhou ${ach.reward} DATA.`);
    } else {
        alert("Ainda não concluiu esta conquista ou já foi resgatada!");
    }
}

// --- 2. PERFIL E ESTATÍSTICAS ---
function updateProfileUI() {
    const panel = document.getElementById('profile-stats');
    if (!panel) return;
    
    const stats = GameData.stats || { battlesWon: 0, floorsCleared: 0, gachaRolls: 0 };
    panel.innerHTML = `
        <p>🏆 Batalhas Vencidas: <b>${stats.battlesWon || 0}</b></p>
        <p>🗺️ Andares Conquistados: <b>${stats.floorsCleared || 0}</b></p>
        <p>🎁 Invocações Gacha: <b>${stats.gachaRolls || 0}</b></p>
        <p>💰 Moedas DATA Atuais: <b>${GameData.dataCurrency || 0}</b></p>
    `;
}

// --- 3. SISTEMA DE GACHA (INSCRIÇÃO DE CRIATURAS) ---
function rollGacha() {
    const cost = 80;
    if ((GameData.dataCurrency || 0) < cost) {
        document.getElementById('gacha-result').innerText = "DATA insuficiente! Precisa de 80 DATA.";
        return;
    }

    GameData.dataCurrency -= cost;
    if (!GameData.stats) GameData.stats = { battlesWon: 0, floorsCleared: 0, gachaRolls: 0 };
    GameData.stats.gachaRolls++;

    // Criaturas possíveis de invocar
    const pool = [
        { id: 'voltrak', name: 'Voltrak', element: 'Elétrico', hp: 90, maxHp: 90, atk: 26, def: 6, level: 1, xp: 0, maxXp: 100 },
        { id: 'frostbite', name: 'Frostbite', element: 'Gelo', hp: 105, maxHp: 105, atk: 22, def: 14, level: 1, xp: 0, maxXp: 100 },
        { id: 'metallix', name: 'Metallix', element: 'Metal', hp: 140, maxHp: 140, atk: 20, def: 18, level: 1, xp: 0, maxXp: 100 }
    ];

    const randomIndex = Math.floor(Math.random() * pool.length);
    const rewardCreature = pool[randomIndex];

    // Verificar se já tem a criatura
    const exists = GameData.creatures.some(c => c.id === rewardCreature.id);
    if (!exists) {
        GameData.creatures.push(rewardCreature);
        document.getElementById('gacha-result').innerText = `🎉 Sucesso! Descodificou uma nova criatura: ${rewardCreature.name} (${rewardCreature.element})!`;
    } else {
        GameData.dataCurrency += 30; // Reembolso parcial se repetida
        document.getElementById('gacha-result').innerText = `✨ Já possuía o ${rewardCreature.name}. Recebeu 30 DATA de reembolso!`;
    }

    saveGameData();
}

// --- 4. MINERAÇÃO PASSIVA OFFLINE (IDLE) ---
function checkOfflineEarnings() {
    const now = Date.now();
    const lastTime = GameData.lastActiveTime || now;
    const diffSeconds = Math.floor((now - lastTime) / 1000);

    // Ganha 1 DATA por cada 30 segundos offline (máximo de 2 horas acumuladas)
    const earnedData = Math.min(Math.floor(diffSeconds / 30), 240);

    if (earnedData > 1) {
        GameData.dataCurrency = (GameData.dataCurrency || 100) + earnedData;
        alert(`🤖 Mineração Passiva: A sua equipa gerou +${earnedData} DATA enquanto esteve ausente da rede!`);
    }

    GameData.lastActiveTime = now;
    saveGameData();
}

// Executar verificação offline ao carregar o jogo
window.addEventListener('load', () => {
    setTimeout(checkOfflineEarnings, 1000);
});
// --- SISTEMA DE ANÚNCIOS RECOMPENSADOS (MONETIZAÇÃO) ---
function watchAdReward() {
    alert("A ligar ao servidor de publicidade da rede...");
    
    setTimeout(() => {
        GameData.dataCurrency = (GameData.dataCurrency || 100) + 50;
        saveGameData();
        
        // Se houver ecrãs abertos que mostrem o saldo ou perfil, atualiza-os
        if (typeof updateProfileUI === 'function') {
            updateProfileUI();
        }
        
        alert("✅ Anúncio concluído com sucesso! Recebeu +50 DATA.");
    }, 1500);
}

