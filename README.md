# bioNX: Automated Knowledge Graph construction of PPI networks

## About the Project

The exponential accumulation of biological data presents a formidable challenge when it comes to integration and extraction of actionable insights. The `bioNX` platform aims to employ automated Knowledge Graph construction using Neo4j in order to provide a portable and user-friendly solution for researchers and labs investigating protein-protein interaction networks (PPIs).

A `bioNX` Knowledge Graph allows the linking of biological data across disparate sources including as databases, APIs, literature and websites. It can provide insight to the relationships between nodes, which can be anything from academic literature, samples, or experiments, to subjects of inquiry such as gene products, PPIs, small molecules and disease conditions. It can even catalog GPS coordinates and time series data. 

An advantage of Knowledge Graphs (and graph databases in general) is the ability to access the immediate context of any data point, something that tabular data models (ie., spreadsheets, RDBMS) cannot easily do. This can save time and expedite the discovery process.

`bioNX` is a work in progress.

#### -- Project Status: [Active]

## Data Sources
* [bioGRID](https://thebiogrid.org/) - primary data source for PPIs
* [HGNC](https://www.genenames.org/)
* [PubMed](https://pubmed.ncbi.nlm.nih.gov/)
* [Uniprot](https://www.uniprot.org/)
* [Entrez](https://www.ncbi.nlm.nih.gov/Web/Search/entrezfs.html)

## Usage

Basic CLI usage using MTHFR gene involved in amino acid metabolism:

```bash
bionx build-graph MTHFR
```

Neo4j example query returning genes, interactions, and author for MTHFR gene mentioned in [PubMed article "29229926"](https://pubmed.ncbi.nlm.nih.gov/29229926/):
```cypher
MATCH (gene1:Gene { name: 'MTHFR' })-[:INTERACTS_WITH]-(gene2:Gene),
(gene1)-[:MENTIONED_IN]->(article:Article { pubmed_id:"29229926" })<-[:MENTIONED_IN]-(gene2), (article)<-[:PUBLISHED]-(author:Author), (gene1)-[:INTERACTOR_IN]->(interaction:Interaction)<-[:INTERACTOR_IN]-(gene2)
RETURN gene1, gene2, author, article, interaction;
```
![MTHFR Graph in Neo4j](./img/mthfr-neo4j.png)

*Please note: bioNX is under development.*

## Current Nodes/Relationships (using Cypher syntax)
* `(Gene)-[:INTERACTOR_IN]->(Interaction)`
* `(Gene1)-[:INTERACTS_WITH]-(Gene2)`
* `(Interaction)-[:MENTIONED_IN]->(Article)`
* `(Gene)-[:MENTIONED_IN]->(Article)`
* `(Author)-[:PUBLISHED]->(Article)`

![Neo4j Screenshot](./img/neo4j-screenshot.png)

## Built With

* [Python](https://docs.python.org/3/)
* [Click](https://click.palletsprojects.com/en/7.x/)
* [Neo4j](https://neo4j.com/)

## Roadmap

See the [open issues](https://github.com/abk7777/bioNX/issues) for a list of proposed features (and known issues).

Basic improvements:
* Expand graph schema to include: 
  * Protein complexes
  * Cofactors
  * RNAs
  * KEGG Pathways
  * Post-Translation Modifications
  * Chromosome loci
  * Subcellular location
  * Tissue
  * Organ
  * Condition
  * etc.
* Build command line interface
* Docker integration
* AWS integration (S3, RDS, Lambda etc.)

## Contributing

While the project is still getting off the ground please feel free to start a discussion in the [open issues](https://github.com/abk7777/bioNX/issues). 

## Contact

Gregory Lindsey - [@abk7x4](https://twitter.com/abk7x4) - gclindsey@gmail.com

Project Link: [https://github.com/abk7777/bioNX](https://github.com/abk7777/bioNX)

## License

This project does not yet have a license.