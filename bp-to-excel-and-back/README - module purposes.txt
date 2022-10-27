Splitter:
> Parse blueprint files as dictionaries.
> Split weapons from units: write each to a separate '_bps_before' file (preserving all other 1:m relationships).

Schema maker:
> Build schema for units and weapons, then write the schema for each to separate '_schema' file
(removing any 1:m relationships, since these would require a separate table/schema).

Bps_to_excel:
> Reads in the bps_before files, filters any 1:m relationships from them and then inserts them into their respective
excel sheets using the schemas.

Excel_to_bps:
> Parse dictionaries for each row from each excel sheet. Save these as '_bps_after' files which are merged into the
original '_bps_before' dictionaries before the original blueprint files are updated. This will ensure that the originally
discarded 1:m relationships are included before we overwrite the original blueprints.

How to deal with the Sound class: every key that maps to a 'Sound' value in the original blueprint file is appended with
'_SOUND' when it is parsed into a Python dictionary (before it is written to the 'BPS_BEFORE' files). Once all changes
have been made and the final blueprints are converted to text (so they can overwrite the original .bp files): the keys
marked with '_SOUND' will be reverted back to their original names and will have the Sound constructor prepended onto
their values.