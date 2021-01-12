MATCH (n) DETACH DELETE n;

LOAD CSV WITH HEADERS
FROM 'file:///biogrid_ppi_data.csv' AS line

// Interaction nodes
CREATE (:Interaction { 
	biogrid_id: line.biogrid_interaction_id,
	author: line.author,
    pubmed_id: line.pubmed_id,
    publication_year: line.publication_year,
    publication_title: line.title,
    doi: line.doi,
    journal: line.full_journal_name,
    experimental_system: line.experimental_system,
    experimental_system_type: line.experimental_system_type,
    throughput: line.throughput,
    gene_a: line.official_symbol_interactor_a,
    entrez_id_a: line.entrez_gene_interactor_a,
    synonyms_a: line.synonyms_interactor_a,
    organism_a: line.organism_interactor_a,
    gene_b: line.official_symbol_interactor_b,
    entrez_id_b: line.entrez_gene_interactor_b,
    synonyms_b: line.synonyms_interactor_b,
    organism_b: line.organism_interactor_b    
    });
    
// Create Gene nodes
MATCH (i:Interaction)
WITH split(apoc.text.join(collect(i.gene_a + ", " + i.gene_b), 
	", "), ", ") as genes
UNWIND genes as gene
WITH DISTINCT gene
CREATE (:Gene { name: gene });

// Create (Gene)-[:INTERACTOR_IN]->(Interaction)
MATCH (i:Interaction)
WITH i, split(apoc.text.join(collect(i.gene_a + ", " + i.gene_b), 
	", "), ", ") as genes
UNWIND genes as gene
MATCH (g:Gene { name: gene })
MERGE (g)-[:INTERACTOR_IN]->(i);

// Set Gene node properties
MATCH (i:Interaction)
WITH i, i.gene_a as gene, i.entrez_id_a as entrez_id, i.synonyms_a as synonyms, i.organism_a as organism
MATCH (g:Gene { name: gene })
SET g.entrez_id = entrez_id, g.synonyms = synonyms, g.organism = organism;

MATCH (i:Interaction)
WITH i, i.gene_b as gene, i.entrez_id_b as entrez_id, i.synonyms_b as synonyms, i.organism_b as organism
MATCH (g:Gene { name: gene })
SET g.entrez_id = entrez_id, g.synonyms = synonyms, g.organism = organism;

MATCH (g:Gene) WITH g
SET g.ncbi_url = "<url>", g.wikipedia_url = "<url>", g.locus_type = "<locus type>", 
	g.full_sequence = "<sequence url>", g.chromosome_location = "<location>", 
    g.base_pairs = "<base pairs>";

// Create (Gene1)-[:INTERACTS_WITH]-(Gene2)
MATCH (g1:Gene)-[:INTERACTOR_IN]->(i:Interaction),
	(g2:Gene)-[:INTERACTOR_IN]->(i)
MERGE (g1)-[:INTERACTS_WITH]-(g2);

// Create Article nodes
MATCH (i:Interaction)
WITH DISTINCT [
    i.pubmed_id, 
    i.author, 
    i.publication_year, 
    i.publication_title,
    i.doi
    ] as article_node
CREATE (:Article { 
	pubmed_id: article_node[0],
    author: article_node[1],
    publication_year: article_node[2],
    publication_title: article_node[3],
    doi: article_node[4]
    });

// Create (Interaction)-[:MENTIONED_IN]->(Article)
MATCH (i:Interaction)
WITH i, i.pubmed_id as pubmed_id
MATCH (a:Article) WHERE a.pubmed_id = pubmed_id
MERGE (i)-[:MENTIONED_IN]->(a);

// Create (Gene)-[:MENTIONED_IN]->(Article)
MATCH (i:Interaction)-[:MENTIONED_IN]->(a:Article)
WITH i, a, [i.gene_a, i.gene_b] as genes
MATCH (g:Gene) WHERE g.name IN genes
MERGE (g)-[:MENTIONED_IN]->(a);

// Create Author nodes
MATCH (i:Interaction)
WITH DISTINCT i.author as author
CREATE (a:Author { name: author, publications: "<count>" });

// Create (Author)-[:PUBLISHED]->(Article)
MATCH (a:Article)
WITH a, a.author as author
MATCH (au:Author { name: author })
MERGE (au)-[:PUBLISHED]->(a);