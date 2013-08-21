class Concepts::TechnologyMethod

  include Tripod::Resource
  rdf_type 'http://data.digitalsocial.eu/def/ontology/TechnologyMethod'

  include Concept
  uri_root 'http://data.digitalsocial.eu/def/concept/technology-method/'
  concept_scheme_uri 'http://data.digitalsocial.eu/def/concept-scheme/technology-method'
  broad_concept_uri (resource_uri_root + 'other')
end