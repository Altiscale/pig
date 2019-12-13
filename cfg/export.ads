artifacts builderVersion: "1.1", {

  group "com.sap.bds.ats-altiscale", {

    artifact "pig", {
      file "${gendir}/src/pigrpmbuild/pig-artifact/alti-pig-${buildVersion}.rpm"
    }
  }
}