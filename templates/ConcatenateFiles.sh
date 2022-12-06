#!/bin/bash

!{params.JAVA} -Djava.io.tmpdir="$TMPDIR" \
-Xms!{javaMem}m -Xmx!{javaMem}m \
-cp /opt/nf-referencebuilder.jar \
org.cruk.pipelines.referencegenomes.ConcatenateFiles \
-o "!{outputFile}" \
!{inputFiles}
