# CFChem

CFChem refers to the CFDE Cheminformatics Database and Development System,
designed for chemicals (small molecules) with data from one or multiple
Common Fund projects and datasets.

## Dependencies

* [RDKit](https://www.rdkit.org/)
* [GitHub:rdkit-tools](https://github.com/jeremyjyang/rdkit-tools) 
* [PostgreSql](https://www.postgresql.org/)

## CFChemDb Workflow

The CFChemDb can be built with the following workflow.

```
Go\_cfchem\_DbCreate.sh
Go\_cfchem\_DbLoad\_IDG.sh
Go\_cfchem\_DbLoad\_LINCS.sh
Go\_cfchem\_DbLoad\_RefMet.sh
Go\_cfchem\_DbLoad\_GlyGen.sh
Go\_cfchem\_DbLoad\_ReproTox.sh
Go\_cfchem\_DbPostprocess.sh
```

## Testing

```
Go\_cfchem\_DbTest.sh
```
