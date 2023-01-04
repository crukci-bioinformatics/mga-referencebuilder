#!/bin/bash

java -Djava.io.tmpdir="$TMPDIR" \
-Xms!{javaMem}m -Xmx!{javaMem}m \
-cp !{params.REFBUILDER} \
org.cruk.pipelines.referencegenomes.NCBIAssembler \
-u "!{urlFile}" \
-o "!{outputFile}" \
-r !{task.cpus - 1}
