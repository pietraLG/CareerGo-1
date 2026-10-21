// ===== DADOS =====
// Os 6 status do CareerGo, cada um com sua cor
const STATUS = [
  { nome: "Candidatura enviada", cor: "#3B82F6" },
  { nome: "Em análise",          cor: "#F59E0B" },
  { nome: "Entrevista",          cor: "#8B5CF6" },
  { nome: "Teste",               cor: "#F97316" },
  { nome: "Aprovado",            cor: "#22C55E" },
  { nome: "Rejeitado",           cor: "#EF4444" }
];

// Vagas de exemplo (no app real virão do Firestore). dias = há quantos dias foi publicada
const vagas = [
  { id: 1, titulo: "Estágio em Desenvolvimento", empresa: "TechNova", local: "São Paulo - SP", modalidade: "Híbrido", contrato: "Estágio", salario: 1800, dias: 0,
    descricao: "Apoiar o time de desenvolvimento na criação e manutenção de aplicativos.", requisitos: ["Cursando Informática ou áreas afins", "Noções de lógica de programação", "Vontade de aprender"] },
  { id: 2, titulo: "Jovem Aprendiz - TI", empresa: "Banco Alfa", local: "Rio de Janeiro - RJ", modalidade: "Presencial", contrato: "Jovem Aprendiz", salario: 1500, dias: 2,
    descricao: "Auxiliar no suporte aos sistemas internos e atendimento aos colaboradores.", requisitos: ["Ensino médio em andamento", "Boa comunicação", "Interesse em tecnologia"] },
  { id: 3, titulo: "Suporte Técnico Júnior", empresa: "RedeSul", local: "Curitiba - PR", modalidade: "Presencial", contrato: "CLT", salario: 2600, dias: 5,
    descricao: "Atender chamados, instalar softwares e manter computadores funcionando.", requisitos: ["Conhecimento em Windows", "Noções de redes", "Experiência em atendimento é diferencial"] },
  { id: 4, titulo: "Desenvolvedor Flutter Júnior", empresa: "AppLab", local: "Remoto", modalidade: "Remoto", contrato: "PJ", salario: 4500, dias: 1,
    descricao: "Desenvolver telas e integrações de aplicativos móveis com Flutter e Firebase.", requisitos: ["Flutter e Dart básicos", "Git e GitHub", "Portfólio com projetos"] },
  { id: 5, titulo: "Estágio em Suporte de TI", empresa: "Clínica Vida", local: "Belo Horizonte - MG", modalidade: "Presencial", contrato: "Estágio", salario: 1400, dias: 7,
    descricao: "Dar suporte aos computadores e impressoras da clínica.", requisitos: ["Cursando Informática", "Organização", "Disponibilidade 6h/dia"] },
  { id: 6, titulo: "Analista de Dados Júnior", empresa: "DadosPlus", local: "Salvador - BA", modalidade: "Híbrido", contrato: "CLT", salario: 3800, dias: 3,
    descricao: "Montar relatórios e painéis para apoiar decisões da empresa.", requisitos: ["Excel intermediário", "Noções de SQL", "Raciocínio analítico"] },
  { id: 7, titulo: "Estágio em Design de Interfaces", empresa: "Pixel Studio", local: "São Paulo - SP", modalidade: "Remoto", contrato: "Estágio", salario: 1700, dias: 4,
    descricao: "Criar protótipos de telas e ajudar na identidade visual de produtos digitais.", requisitos: ["Noções de Figma", "Senso estético", "Portfólio simples"] },
  { id: 8, titulo: "Técnico em Redes", empresa: "ConectaNet", local: "Rio de Janeiro - RJ", modalidade: "Presencial", contrato: "CLT", salario: 3200, dias: 9,
    descricao: "Instalar e manter redes de computadores em empresas parceiras.", requisitos: ["Curso técnico em Informática", "Cabeamento e roteadores", "CNH B é diferencial"] }
];

// ===== ESTADO (o que o usuário fez) =====
let candidaturas = [];   // { vagaId, status, data }
let favoritos = [];      // ids das vagas favoritas
let vagaAtual = 1;       // vaga aberta nos detalhes

const $ = function (id) { return document.getElementById(id); };
const dinheiro = function (n) { return n.toLocaleString("pt-BR", { style: "currency", currency: "BRL", maximumFractionDigits: 0 }); };
const quando = function (d) { return d === 0 ? "Publicada hoje" : "Publicada há " + d + (d === 1 ? " dia" : " dias"); };
const achar = function (id) { return vagas.find(function (v) { return v.id === id; }); };

// ===== READ: filtrar e listar vagas =====
function filtrar() {
  const cargo = $("cargo").value.toLowerCase().trim();
  const local = $("local").value.toLowerCase().trim();
  const mod = $("fModalidade").value;
  const con = $("fContrato").value;

  const lista = vagas.filter(function (v) {
    return (v.titulo + " " + v.empresa).toLowerCase().includes(cargo) &&
           v.local.toLowerCase().includes(local) &&
           (mod === "" || v.modalidade === mod) &&
           (con === "" || v.contrato === con);
  });
  if ($("ordem").value === "recentes") lista.sort(function (a, b) { return a.dias - b.dias; });
  return lista;
}

function cartaoVaga(v, extra) {
  const fav = favoritos.includes(v.id);
  return '<li><button type="button" class="card ' + (v.id === vagaAtual && extra === "sel" ? "ativa" : "") + '" data-abrir="' + v.id + '">' +
    "<b>" + v.titulo + "</b><small>" + v.empresa + " · " + v.local + "</small>" +
    "<small>" + v.modalidade + " · " + v.contrato + " · " + dinheiro(v.salario) + "</small>" +
    "<small>" + quando(v.dias) + "</small></button>" +
    '<button type="button" class="coracao ' + (fav ? "on" : "") + '" data-fav="' + v.id + '" aria-label="Favoritar vaga">' + (fav ? "♥" : "♡") + "</button></li>";
}

function desenharVagas() {
  const lista = filtrar();
  $("contagem").textContent = lista.length + (lista.length === 1 ? " vaga encontrada" : " vagas encontradas");
  $("listaVagas").innerHTML = lista.length ? lista.map(function (v) { return cartaoVaga(v, "sel"); }).join("") :
    '<li class="vazio">Nenhuma vaga com esses filtros. Tente limpar a busca.</li>';
  desenharDetalhe();
}

function desenharDetalhe() {
  const v = achar(vagaAtual);
  const jaCand = candidaturas.some(function (c) { return c.vagaId === v.id; });
  const fav = favoritos.includes(v.id);
  $("detalhe").innerHTML =
    "<h2>" + v.titulo + "</h2><div>" + v.empresa + "</div>" +
    '<div class="etiquetas"><span class="etiqueta">' + v.local + '</span><span class="etiqueta">' + v.modalidade +
    '</span><span class="etiqueta">' + v.contrato + '</span><span class="etiqueta">' + quando(v.dias) + "</span></div>" +
    '<div class="salario">' + dinheiro(v.salario) + "</div>" +
    '<div class="acoes"><button type="button" class="botao" data-cand="' + v.id + '"' + (jaCand ? " disabled" : "") + ">" +
    (jaCand ? "Candidatura enviada" : "Quero me candidatar") + "</button>" +
    '<button type="button" class="botao claro" data-fav="' + v.id + '">' + (fav ? "Remover dos favoritos" : "Favoritar") + "</button></div>" +
    "<h3>Sobre a vaga</h3><p>" + v.descricao + "</p><h3>Requisitos</h3><ul>" +
    v.requisitos.map(function (r) { return "<li>" + r + "</li>"; }).join("") + "</ul>";
}

// ===== CREATE: candidatar-se (cria uma candidatura com status inicial) =====
function candidatar(id) {
  if (candidaturas.some(function (c) { return c.vagaId === id; })) return;
  candidaturas.push({ vagaId: id, status: 0, data: new Date().toLocaleDateString("pt-BR") });
  atualizarTudo();
}

// ===== UPDATE: favoritar / desfavoritar =====
function favoritar(id) {
  if (favoritos.includes(id)) favoritos = favoritos.filter(function (f) { return f !== id; });
  else favoritos.push(id);
  atualizarTudo();
}

// ===== Candidaturas: resumo, lista, UPDATE do status e DELETE =====
function desenharCandidaturas() {
  const conta = function (s) { return candidaturas.filter(function (c) { return c.status === s; }).length; };
  $("resumo").innerHTML =
    "<div><b>" + candidaturas.length + "</b><span>Total</span></div>" +
    "<div><b>" + conta(1) + "</b><span>Em análise</span></div>" +
    "<div><b>" + conta(2) + "</b><span>Entrevistas</span></div>" +
    "<div><b>" + conta(4) + "</b><span>Aprovadas</span></div>" +
    "<div><b>" + conta(5) + "</b><span>Rejeitadas</span></div>";

  $("listaCand").innerHTML = candidaturas.length ? candidaturas.map(function (c) {
    const v = achar(c.vagaId), s = STATUS[c.status];
    const opcoes = STATUS.map(function (o, i) { return '<option value="' + i + '"' + (i === c.status ? " selected" : "") + ">" + o.nome + "</option>"; }).join("");
    return '<li><div class="card fixo"><b>' + v.titulo + "</b><small>" + v.empresa + " · enviada em " + c.data + "</small>" +
      '<div class="linha"><span class="chip" style="--cor:' + s.cor + '">' + s.nome + "</span>" +
      '<select data-status="' + c.vagaId + '" aria-label="Alterar status">' + opcoes + "</select>" +
      '<button type="button" class="perigo" data-excluir="' + c.vagaId + '">Excluir</button></div></div></li>';
  }).join("") : '<li class="vazio">Você ainda não se candidatou. Abra uma vaga e clique em "Quero me candidatar".</li>';
}

function desenharFavoritos() {
  $("listaFav").innerHTML = favoritos.length ? favoritos.map(function (id) { return cartaoVaga(achar(id), ""); }).join("") :
    '<li class="vazio">Nenhuma vaga favorita ainda. Use o coração nas vagas.</li>';
}

function atualizarTudo() {
  $("qtdCand").textContent = candidaturas.length;
  $("qtdFav").textContent = favoritos.length;
  desenharVagas();
  desenharCandidaturas();
  desenharFavoritos();
}

function trocarAba(nome) {
  ["vagas", "candidaturas", "favoritos"].forEach(function (a) { $("aba-" + a).hidden = (a !== nome); });
  document.querySelectorAll(".abas button").forEach(function (b) { b.classList.toggle("ativa", b.dataset.aba === nome); });
}

// ===== EVENTOS =====
document.addEventListener("click", function (e) {
  const alvo = e.target.closest("button");
  if (!alvo) return;
  if (alvo.dataset.aba) trocarAba(alvo.dataset.aba);
  if (alvo.dataset.abrir) {
    vagaAtual = Number(alvo.dataset.abrir);
    trocarAba("vagas");
    desenharVagas();
    if (window.innerWidth < 860) $("detalhe").scrollIntoView({ behavior: "smooth" });
  }
  if (alvo.dataset.fav) favoritar(Number(alvo.dataset.fav));
  if (alvo.dataset.cand) candidatar(Number(alvo.dataset.cand));
  if (alvo.dataset.excluir && confirm("Excluir esta candidatura?")) {   // DELETE com confirmação
    const id = Number(alvo.dataset.excluir);
    candidaturas = candidaturas.filter(function (c) { return c.vagaId !== id; });
    atualizarTudo();
  }
});

document.addEventListener("change", function (e) {
  if (e.target.dataset.status) {   // UPDATE: troca o status da candidatura
    const c = candidaturas.find(function (x) { return x.vagaId === Number(e.target.dataset.status); });
    c.status = Number(e.target.value);
    atualizarTudo();
  }
});

["cargo", "local"].forEach(function (id) { $(id).addEventListener("input", desenharVagas); });
["fModalidade", "fContrato", "ordem"].forEach(function (id) { $(id).addEventListener("change", desenharVagas); });
$("btnBuscar").addEventListener("click", desenharVagas);
$("btnLimpar").addEventListener("click", function () {
  $("cargo").value = ""; $("local").value = ""; $("fModalidade").value = ""; $("fContrato").value = ""; $("ordem").value = "relevancia";
  desenharVagas();
});

atualizarTudo();