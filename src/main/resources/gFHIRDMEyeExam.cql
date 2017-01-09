library gFHIRDMEyeExam version '1'

using gFHIR

valueset "Negative": '2.16.840.1.113883.3.464.1003.195.12.1002'
valueset "Diabetes": '2.16.840.1.113883.3.464.1003.103.12.1001'
valueset "EyeExam": '2.16.840.1.113883.3.464.1003.115.12.1088'
valueset "Ophthalmologist": '2.16.840.1.113883.3.526.3.1285'

define diabetesConditionList: [Condition: code in "Diabetes"] C
define retinalDilatedEyeExam: [Observation: code in "EyeExam"] O where O.effectiveDateTime during Interval[Now() - 2 years, Now() - 1 years]
define eyeExamProcedureRequest: [ProcedureRequest: code in "EyeExam"] P
define ophthalmologistEncounterVisitList: [Encounter] E

context Patient
define isInAgeRange: AgeInYears() >= 18 and AgeInYears() <= 85
define hasDiabetes: exists( diabetesConditionList C where
                           C.clinicalStatus in {'active', 'relapse'} and
                           C.verificationStatus in {'preliminary','confirmed'}
                          )

define isInPopulation: isInAgeRange and hasDiabetes

define hasEyeExam: exists( eyeExamProcedureRequest E where E.scheduledDateTime during Interval[Now() - 2 years, Now() - 1 years] and E.status = 'completed')
define hasEyeExamObservation: exists( retinalDilatedEyeExam)
define mostRecentEyeExam: First( retinalDilatedEyeExam O sort by O.effectiveDateTime desc )
define hasNegativeEyeExamResult: if hasEyeExamObservation
  								 then mostRecentEyeExam.valueCodeableConcept.coding[0].code in "Negative"
  								 else false

define hasOphthalmologistVisit: exists(ophthalmologistEncounterVisitList V where V.classElement = 'outpatient' and V.status = 'finished' and V.participantCode in "Ophthalmologist" and V.periodstart during Interval[Now() - 1 years, Now()])

define needsEyeExam: if isInPopulation
  					 then not hasEyeExam and
  					 	  not hasNegativeEyeExamResult and
  					 	  not hasOphthalmologistVisit
  					 else
  					      // EDIT: changed from null to false
  					      false
