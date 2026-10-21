class Categoria {
  final String nome; // o que aparece no chip
  final String tag; // o que a Adzuna entende
  const Categoria(this.nome, this.tag);
}

const categorias = [
  Categoria('Tecnologia', 'it-jobs'),
  Categoria('Vendas', 'sales-jobs'),
  Categoria('Atendimento', 'customer-services-jobs'),
  Categoria('Finanças', 'accounting-finance-jobs'),
  Categoria('Administrativo', 'admin-jobs'),
  Categoria('Saúde', 'healthcare-nursing-jobs'),
  Categoria('Ensino', 'teaching-jobs'),
  Categoria('Engenharia', 'engineering-jobs'),
  Categoria('Logística', 'logistics-warehouse-jobs'),
  Categoria('Varejo', 'retail-jobs'),
  Categoria('Construção', 'trade-construction-jobs'),
  Categoria('Hospitalidade', 'hospitality-catering-jobs'),
  Categoria('Marketing', 'pr-advertising-marketing-jobs'),
  Categoria('Recursos Humanos', 'hr-jobs'),
  Categoria('Jurídico', 'legal-jobs'),
  Categoria('Design', 'creative-design-jobs'),
  Categoria('Indústria', 'manufacturing-jobs'),
  Categoria('Manutenção', 'maintenance-jobs'),
  Categoria('Limpeza', 'domestic-help-cleaning-jobs'),
  Categoria('Turismo', 'travel-jobs'),
  Categoria('Imóveis', 'property-jobs'),
  Categoria('Consultoria', 'consultancy-jobs'),
  Categoria('Serviços sociais', 'social-work-jobs'),
  Categoria('Ciência e Qualidade', 'scientific-qa-jobs'),
  Categoria('Petróleo e Gás', 'energy-oil-gas-jobs'),
  Categoria('Recém formados', 'graduate-jobs'),
  Categoria('Meio período', 'part-time-jobs'),
  Categoria('Voluntariado', 'charity-voluntary-jobs'),
  Categoria('Outras', 'other-general-jobs'),
];