library COL version '1'

using gFHIR

//include FHIRHelpers version '1.6' called FHIRHelpers

codesystem "CPT": 'urn:oid:2.16.840.1.113883.6.12'
codesystem "SNOMED-CT": 'http://snomed.info/sct' //'urn:oid:2.16.840.1.113883.6.96'
codesystem "LOINC": 'http://loinc.org'

parameter MeasurementPeriod default Interval[Today(), Today()]

context Patient

define "Malignant Neoplasm of Colon":
    { Code '363414004' from "SNOMED-CT", Code '285312008' from "SNOMED-CT" }

define "Total Colectomy":
    { Code '36192008' from "SNOMED-CT" }

define "Colonoscopy":
    { Code '174158000' from "SNOMED-CT" }

define "Flexible Sigmoidoscopy":
    { Code '396226005' from "SNOMED-CT" }

define "Fecal Occult Blood Test (FOBT)":
    { Code '27396-1' from "LOINC", Code '58453-2' from "LOINC" }

define "Lookback Interval One Year":
  Interval[start of MeasurementPeriod - 1 years, end of MeasurementPeriod]

define "Lookback Interval Five Years":
  Interval[start of MeasurementPeriod - 5 years, end of MeasurementPeriod]

define "Lookback Interval Ten Years":
  Interval[start of MeasurementPeriod - 10 years, end of MeasurementPeriod]

define "In Demographic":
    AgeInYearsAt(start of MeasurementPeriod) >= 50

define "Hx Colorectal Cancer":
  [Condition: "Malignant Neoplasm of Colon"] C
    where C.clinicalStatus = 'active'
      and C.verificationStatus = 'confirmed'

define "Hx Total Colectomy":
  [Procedure: "Total Colectomy"] T
    where T.status.value = 'completed'

define "Colonoscopy Performed":
  [Procedure: "Colonoscopy"] C
    where C.status.value = 'completed'
      and C.performedPeriod."end" during "Lookback Interval Ten Years"

define "Colonoscopy Results":
  [Observation: "Colonoscopy"] C
    where C.status = 'final'
      and C.effectiveDateTime during "Lookback Interval Ten Years"

// Hx Sigmoidoscopy - Most recent historic sigmoidoscopy date, results/findings must be provided

define "Sigmoidoscopy Procedure":
  [Procedure: "Flexible Sigmoidoscopy"] S
    where S.status.value = 'completed'
      and S.performedPeriod."end" during "Lookback Interval Five Years"

define "Sigmoidoscopy Observation":
  [Observation: "Flexible Sigmoidoscopy"] O
    where O.status = 'final'
      and O.effectiveDateTime during "Lookback Interval Five Years"


define "FOBT Procedure":
  [Procedure: "Fecal Occult Blood Test (FOBT)"] F
    where F.status.value = 'completed'
      and F.performedPeriod."end" during "Lookback Interval One Year"

define "FOBT Observation":
  [Observation: "Fecal Occult Blood Test (FOBT)"] O
    where O.status = 'final'
      and O.effectiveDateTime during "Lookback Interval One Year"

define "Colonoscopy Procedure":
  [Procedure: "Colonoscopy"] C
    where C.status.value = 'completed'
      and C.performedPeriod."end" during "Lookback Interval Ten Years"

define "Colonoscopy Observation":
  [Observation: "Colonoscopy"] O
    where O.status = 'final'
      and O.effectiveDateTime during "Lookback Interval Ten Years"
