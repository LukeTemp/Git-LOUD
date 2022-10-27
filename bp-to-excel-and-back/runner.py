from pathlib import Path
import os
import pickle as pickle
from dictionary_transformations import filterDict
import loud_bp_splitter
import loud_bp_schema_builder
import loud_bps_to_excel
import loud_excel_to_bps
import loud_bp_dump_comparer

dirs = ['C:/Program Files (x86)/Steam/steamapps/common/Supreme Commander Forged Alliance/Git-LOUD/gamedata/']
logging = False
categories = set({}) #{'AEON', 'MOBILE'}
file_prefix = 'ALL' #'AEON-MOBILE'

loud_bp_splitter.main(dirs,categories,file_prefix,logging)
loud_bp_schema_builder.main(file_prefix)
loud_bps_to_excel.main(file_prefix)
loud_excel_to_bps.main(file_prefix)
loud_bp_dump_comparer.main(file_prefix)
