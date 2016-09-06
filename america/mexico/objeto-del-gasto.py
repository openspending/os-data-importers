from datapackage_pipelines.wrapper import ingest, spew

params, datapackage, res_iter = ingest()

columns = params.get('columns')


new_columns = [
    'Partida Genérica',
    'Partida Específica',
    'Descripción de Partida Específica',
    'Descripción de Partida Genérica',
    'Capitulo',
    'Descripción de Capitulo',
    'Concepto',
    'Descripción de Concepto',
]

for column in new_columns:
    datapackage['resources'][0]['schema']['fields'].append({
        'name': column,
        'type': 'string'
    })


def lookup(value, catalog, year):
    return '{}/{}/{}'.format(year, catalog, value)


def process_row(row):
    year = row['Ciclo']

    # Skip the LAST year of the dataset (currently 2016) it has split columns already
    if year >= '2016':
        return row

    objeto = row['Objeto del Gasto']
    if objeto:
        row['Capitulo'] = objeto[0] + '000'
        row['Concepto'] = objeto[:2] + '00'
        row['Descripción de Capitulo'] = lookup(row['Capitulo'], 'capitulo', year)
        row['Descripción de Concepto'] = lookup(row['Concepto'], 'concepto', year)

        if len(objeto) == 4:
            row['Partida Genérica'] = objeto[:3]

        row['Descripción de Partida Genérica'] = lookup(row.get('Partida Genérica'), 'partida_generica', year)

    try:
        int(year)
    except:
        import logging
        logging.error('RRR '+repr(row))

    if int(year) not in (2008, 2009, 2010):
        if len(objeto) == 5:
            row['Partida Específica'] = objeto
            row['Descripción de Partida Específica'] = lookup(row['Partida Específica'], 'partida_especifica', year)

    return row


def process_resources(_res_iter):
    for rows in _res_iter:
        def process_rows(_rows):
            for row in _rows:
                yield process_row(row)
        yield process_rows(rows)

spew(datapackage, process_resources(res_iter))
