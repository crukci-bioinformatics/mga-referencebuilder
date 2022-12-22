#!/bin/bash

java -Djava.io.tmpdir="$TMPDIR" \
-Xms!{javaMem}m -Xmx!{javaMem}m \
-cp /opt/mga-referencebuilder.jar \
org.cruk.pipelines.referencegenomes.ConcatenateFiles \
-o "!{outputFile}" \
!{inputFiles}
