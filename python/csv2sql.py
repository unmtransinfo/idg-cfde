#!/usr/bin/env python3
"""
Convert CSV to INSERTS for a specified table, with
control over column names, datatypes, and database systems (dbsystem).
"""
#
import sys,os,argparse,re,gzip,logging
import numpy as np
import pandas as pd
#
PROG=os.path.basename(sys.argv[0])
#
#############################################################################
def CsvCheck(fin, dbsystem, noheader, maxchar, delim, qc, keywords):
  df = pd.read_csv(fin, sep=delim, header=(None if noheader else 0), quotechar=qc)
  n_err=0;
  if noheader:
    prefix = re.sub(r'\..*$','', os.path.basename(fin.name))
    df.columns = [f"{prefix}_{j}" for j in range(1, 1+df.shape[1])]
  else:
    colnames_clean = CleanNames(df.columns, '', keywords)
    colnames_clean = DedupNames(colnames_clean)
    for j in range(len(colnames)):
      tag = df.columns[j]
      tag_clean = colnames_clean[j]
      logging.debug(f"column tag {j+1}: {tag:24s}"+(f" -> {tag_clean}" if tag_clean!=tag else ""))
    df.columns = colnames_clean
  nval = {colname:0 for colname in df.columns}
  maxlen = {colname:0 for colname in df.columns}
  for i in range(df.shape[0]):
    row = df.iloc[i,]
    for j in range(row.size):
      val = row.values[j]
      try:
        if type(val) is str:
          val = val.encode('ascii', 'replace')
      except Exception as e:
        logging.error(f"[{i}] {str(e)}")
        val = f"{PROG}:ENCODING_ERROR"
        n_err+=1
      if val.strip(): nval[colname]+=1
      val = EscapeString(val, False, dbsystem)
      maxlen[colname] = max(maxlen[colname], len(val))
      if len(val)>maxchar:
        logging.warning(f"[{i}] len>MAX ({len(val)}>{maxchar})")
        val = val[:maxchar]
  for j,tag in enumerate(df.columns):
    logging.info(f"{j+1}. '{tag:24s}': nval = {nval[tag]:6d} maxlen = {maxlen[tag]:6d}")
  logging.info(f"i: {i}; n_err: {n_err}")

#############################################################################
def Csv2Create(fin, fout, dbsystem, dtypes, schema, tablename, colnames, coltypes, prefix, noheader, fixtags, delim, qc, keywords):
  df = pd.read_csv(fin, sep=delim, header=(None if noheader else 0), quotechar=qc)
  if colnames:
    if len(colnames) != df.shape[1]:
      logging.error(f"#colnames)!=#fieldnames ({len(colnames)}!={df.shape[1]})")
      return
    df.columns = colnames
    if fixtags:
      colnames_clean = CleanNames(df.columns, prefix, keywords)
      df.columns = DedupNames(colnames_clean)
  if coltypes:
    if len(coltypes) != df.shape[1]:
      logging.error(f"#coltypes!=#fieldnames ({len(coltypes)}!={df.shape[1]})")
      return
    for j in range(len(coltypes)):
      if not coltypes[j]: coltypes[j] = 'CHAR'
  else:
    coltypes = [dtypes['deftype'] for i in range(df.shape[1])]
  if dbsystem=='mysql':
    sql = f"CREATE TABLE {tablename} ("+"\n\t"
  else:
    sql = f"CREATE TABLE {schema}.{tablename} ("+"\n\t"
  sql += (',\n\t'.join((f"{df.columns[j]} {dtypes[dbsystem][coltypes[j]]}") for j in range(df.shape[1])))
  sql += ('\n);')
  if dbsystem=='postgres':
    sql += f"\nCOMMENT ON TABLE {schema}.{tablename} IS 'Created by {PROG}.';"
  fout.write(sql+'\n')
  logging.info(f"{tablename}: output SQL CREATE written, columns: {df.shape[1]}")

#############################################################################
def Csv2Insert(fin, fout, dbsystem, dtypes, schema, tablename, colnames, coltypes, prefix, noheader, nullwords, nullify, fixtags, maxchar, chartypes, numtypes, timetypes, delim, qc, keywords, skip, nmax):
  n_out=0; n_err=0;
  df = pd.read_csv(fin, sep=delim, header=(None if noheader else 0), quotechar=qc)
  if colnames:
    if len(colnames) != df.shape[1]:
      logging.error(f"#colnames)!=#fieldnames ({len(colnames)}!={df.shape[1]})")
      return
    df.columns = colnames
    if fixtags:
      colnames_clean = CleanNames(df.columns, prefix, keywords)
      df.columns = DedupNames(colnames_clean)
  if coltypes:
    if len(coltypes) != df.shape[1]:
      logging.error(f"#coltypes!=#fieldnames ({len(coltypes)}!={df.shape[1]})")
      return
    for j in range(len(coltypes)):
      if not coltypes[j]: coltypes[j] = 'CHAR'
  else:
    coltypes = [dtypes['deftype'] for i in range(df.shape[1])]
  for j in range(len(coltypes)):
    if not coltypes[j]: coltypes[j]=dtypes['deftype']
  for i in range(df.shape[0]):
    row = df.iloc[i,]
    if i<=skip: continue
    if dbsystem=='mysql':
      line = (f"INSERT INTO {tablename} ({','.join(df.columns)}) VALUES (")
    else:
      line = (f"INSERT INTO {schema}.{tablename} ({','.join(df.columns)}) VALUES (")
    for j,colname in enumerate(df.columns):
      val = row[colname]
      #logging.debug("%s: '%s'"%(colname, val))
      if coltypes[j].upper() in chartypes:
        val = EscapeString(str(val), dbsystem)
        if val.strip()=='' and nullify: val='NULL'
        if len(val)>maxchar:
          val = val[:maxchar]
          logging.warning(f"[row={i}] string truncated to {maxchar} chars: '{val}'")
        val = (f"'{val}'")
      elif coltypes[j].upper() in numtypes:
        try:
          if type(val) is str:
            val = 'NULL' if val.upper() in nullwords else (f"{val}")
          else:
            val = 'NULL' if (np.isnan(val) or pd.isna(val) or str(val)=='nan') else (f"{val}")
        except Exception as e:
          logging.debug(f"{e}")
          logging.debug(f"val: {val}; type(val): {type(val)}")
          val = 'NULL'
      elif coltypes[j].upper() in timetypes:
        val = (f"to_timestamp('{val}')")
      else:
        logging.error(f"No type specified or implied: (col={j+1})")
        continue
      line+=(f"{(',' if j>0 else '')}{val}")
    line += (') ;')
    fout.write(line+'\n')
    n_out+=1
    if i==nmax: break
  logging.info(f"{tablename}: input CSV lines: {i}; output SQL inserts: {n_out}")

#############################################################################
def CleanName(name, keywords):
  '''Clean table or col name for use without escaping.
* Strip leading and trailing whitespace.
* Downcase.
* Replace spaces and colons with underscores.
* Remove punctuation and special chars.
* Prepend leading numeral.
* Truncate to 50 chars.
* Fix if in keyword list, e.g. "procedure".
'''
  name = name.strip()
  name = re.sub(r'[\s:-]+', '_', name.lower())
  name = re.sub(r'[^\w]', '', name)
  name = re.sub(r'^([\d])', r'col_\1', name)
  name = name[:50]
  if name in keywords:
    name+='_name'
  return name

#############################################################################
def CleanNames(colnames, prefix, keywords):
  colnames_clean = []
  for colname in colnames:
    colnames_clean.append(CleanName(prefix+colname if prefix else colname, keywords))
  return colnames_clean

#############################################################################
def DedupNames(colnames):
  unames = set()
  for j in range(len(colnames)):
    if colnames[j] in unames:
      colname_orig = colnames[j]
      k=1
      while colnames[j] in unames:
        k+=1
        colnames[j] = f"{colname_orig}_{k}"
    unames.add(colnames[j])
  return colnames

#############################################################################
def EscapeString(val, dbsystem):
  val = re.sub(r"'", '', val)
  if dbsystem=='postgres':
    val = re.sub(r'\\', r"'||E'\\\\'||'", val)
  elif dbsystem=='mysql':
    val = re.sub(r'\\', r'\\\\', val)
  return val

#############################################################################
if __name__=='__main__':
  DBSYSTEMS=['postgres', 'mysql', 'oracle', 'derby']; DBSYSTEM='postgres';
  KEYWORDS='procedure,function,column,table'
  MAXCHAR=1024
  CHARTYPES = 'CHAR,CHARACTER,VARCHAR,TEXT'
  NUMTYPES = 'INT,BIGINT,FLOAT,NUM'
  DEFTYPE='CHAR';
  TIMETYPES = 'DATE,TIMESTAMP'
  NULLWORDS = "NULL,UNSPECIFIED,MISSING,UNKNOWN,NA"
  SCHEMA='public';
  QUOTECHAR='"';

  parser = argparse.ArgumentParser(description="CSV to SQL CREATEs or INSERTs", epilog='')
  ops = [
	"insert", # output INSERT statements
	"create", # output CREATE statements
	"check"] # check input file, profile columns

  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--i", dest="ifile", help="input file (CSV|TSV) [stdin]")
  parser.add_argument("--o", dest="ofile", help="output SQL INSERTs [stdout]")
  parser.add_argument("--schema", default=SCHEMA, help="(Postgres schema, or MySql db)")
  parser.add_argument("--tablename", help="table [convert filename]")
  parser.add_argument("--prefix_tablename", help="prefix + [convert filename]")
  parser.add_argument("--dbsystem", default=DBSYSTEM, help="")
  parser.add_argument("--colnames", help="comma-separated [default: CSV tags]")
  parser.add_argument("--noheader", action="store_true", help="auto-name columns")
  parser.add_argument("--prefix_colnames", help="prefix CSV tags")
  parser.add_argument("--coltypes", help="comma-separated [default: all CHAR]")
  parser.add_argument("--nullify", action="store_true", help="CSV missing CHAR value converts to NULL")
  parser.add_argument("--nullwords", default=NULLWORDS, help="words synonymous with NULL (comma-separated list)")
  parser.add_argument("--keywords", default=KEYWORDS, help="keywords, disallowed tablenames (comma-separated list)")
  parser.add_argument("--char_types", default=CHARTYPES, help="character types (comma-separated list)")
  parser.add_argument("--num_types", default=NUMTYPES, help="numeric types (comma-separated list)")
  parser.add_argument("--time_types", default=TIMETYPES, help="time types (comma-separated list)")
  parser.add_argument("--maxchar", type=int, default=MAXCHAR, help="max string length")
  parser.add_argument("--fixtags", action="store_true", help="tags to colnames (downcase/nopunct/nospace)")
  parser.add_argument("--tsv", action="store_true", help="input file TSV")
  parser.add_argument("--igz", action="store_true", help="input file GZ")
  parser.add_argument("--delim", default=",", help="use if not comma or tab")
  parser.add_argument("--default_type", default=DEFTYPE, help="")
  parser.add_argument("--quotechar", default=QUOTECHAR, help="")
  parser.add_argument("--skip", type=int, default=0, help="skip N records (--insert only)")
  parser.add_argument("--nmax", type=int, default=0, help="max N records (--insert only)")
  parser.add_argument("-v", "--verbose", default=0, action="count")
  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  if args.tsv: DELIM='\t'
  else: DELIM = args.delim

  NULLWORDS = re.split(r'[\s,]', args.nullwords)
  KEYWORDS = re.split(r'[\s,]', args.keywords)
  CHARTYPES = re.split(r'[\s,]', args.char_types)
  NUMTYPES = re.split(r'[\s,]', args.num_types)
  TIMETYPES = re.split(r'[\s,]', args.time_types)

  if args.ifile:
    fin = gzip.open(args.ifile) if args.igz else open(args.ifile)
  else:
    fin = sys.stdin

  if args.ofile:
    fout = open(args.ofile,'w')
  else:
    fout = sys.stdout

  if args.tablename:
    TABLENAME = args.tablename
  else:
    if not args.ifile: parser.error('--tablename or --i required.')
    TABLENAME = CleanName(args.prefix_tablename+re.sub(r'\..*$','', os.path.basename(args.ifile)), KEYWORDS)
    logging.debug(f"tablename = '{TABLENAME}'")

  DTYPES = {
	'postgres': {
		'CHAR':f"VARCHAR({args.maxchar})",
		'CHARACTER':f"VARCHAR({args.maxchar})",
		'VARCHAR':f"VARCHAR({args.maxchar})",
		'INT':'INTEGER',
		'BIGINT':'BIGINT',
		'FLOAT':'FLOAT',
		'NUM':'FLOAT',
		'BOOL':'BOOLEAN'
		},
	'mysql': {
		'CHAR':f"TEXT({args.maxchar})",
		'CHARACTER':f"TEXT({args.maxchar})",
		'VARCHAR':f"TEXT({args.maxchar})",
		'INT':'INTEGER',
		'BIGINT':'BIGINT',
		'FLOAT':'FLOAT',
		'NUM':'FLOAT',
		'BOOL':'BOOLEAN'
		}
	}
  DTYPES['deftype'] = args.default_type
  

  if args.op=="create":
    Csv2Create(fin, fout, args.dbsystem,
	DTYPES,
	args.schema,
	TABLENAME,
	re.split(r'[,\s]+', args.colnames) if args.colnames else None,
	re.split(r'[,\s]+', args.coltypes) if args.coltypes else None,
	args.prefix_colnames, args.noheader, args.fixtags, DELIM, args.quotechar,
	KEYWORDS)

  elif args.op=="insert":
    Csv2Insert(fin, fout, args.dbsystem,
	DTYPES,
	args.schema,
	TABLENAME,
	re.split(r'[,\s]+', args.colnames) if args.colnames else None,
	re.split(r'[,\s]+', args.coltypes) if args.coltypes else None,
	args.prefix_colnames, args.noheader,
	NULLWORDS, args.nullify, args.fixtags, args.maxchar,
	CHARTYPES, NUMTYPES, TIMETYPES,
	DELIM, args.quotechar, KEYWORDS, args.skip, args.nmax)

  elif args.op=="check":
    CsvCheck(fin, args.dbsystem, args.noheader, args.maxchar, DELIM, args.quotechar, KEYWORDS)

  else:
    parser.error(f"Invalid operation: {args.op}")

