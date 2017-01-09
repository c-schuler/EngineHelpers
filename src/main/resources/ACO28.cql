library CMS165v5_0_000 version '1.0'
/* CMS 165v5 is the same mesure as ACO28 and NQF 0018. */

using mFHIR

valueset "Diagnosis: Chronic Kidney Disease, Stage 5": '2.16.840.1.113883.3.526.3.1002' version 'MU2 Update 2016-04-01'
valueset "Diagnosis: End Stage Renal Disease": '2.16.840.1.113883.3.526.3.353' version 'MU2 Update 2016-04-01'
valueset "Diagnosis: Essential Hypertension": '2.16.840.1.113883.3.464.1003.104.12.1011' version 'MU2 Update 2016-04-01'
valueset "Diagnosis: Pregnancy": '2.16.840.1.113883.3.526.3.378' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Adult Outpatient Visit": '2.16.840.1.113883.3.464.1003.101.12.1065' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Annual Wellness Visit": '2.16.840.1.113883.3.526.3.1240' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: ESRD Monthly Outpatient Services": '2.16.840.1.113883.3.464.1003.109.12.1014' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Face-to-Face Interaction": '2.16.840.1.113883.3.464.1003.101.12.1048' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Home Healthcare Services": '2.16.840.1.113883.3.464.1003.101.12.1016' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Preventive Care Services-Established Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1025' version 'MU2 Update 2016-04-01'
valueset "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up": '2.16.840.1.113883.3.464.1003.101.12.1023' version 'MU2 Update 2016-04-01'
valueset "Intervention, Performed: Dialysis Education": '2.16.840.1.113883.3.464.1003.109.12.1016' version 'MU2 Update 2016-04-01'
valueset "Intervention, Performed: Other Services Related to Dialysis": '2.16.840.1.113883.3.464.1003.109.12.1015' version 'MU2 Update 2016-04-01'
valueset "Physical Exam, Performed: Diastolic Blood Pressure": '2.16.840.1.113883.3.526.3.1033' version 'MU2 Update 2016-04-01'
valueset "Physical Exam, Performed: Systolic Blood Pressure": '2.16.840.1.113883.3.526.3.1032' version 'MU2 Update 2016-04-01'
valueset "Procedure, Performed: Dialysis Services": '2.16.840.1.113883.3.464.1003.109.12.1013' version 'MU2 Update 2016-04-01'
valueset "Procedure, Performed: Kidney Transplant": '2.16.840.1.113883.3.464.1003.109.12.1012' version 'MU2 Update 2016-04-01'
valueset "Procedure, Performed: Vascular Access for Dialysis": '2.16.840.1.113883.3.464.1003.109.12.1011' version 'MU2 Update 2016-04-01'

// EDIT: changed today() to Today()
parameter MeasurementPeriod default Interval[DateTime(((year from Today()) - 1),  1,  1,  0,  0,  0),
											 DateTime(((year from Today()) - 1), 12, 31, 23, 59, 59)]

context Patient


define InAgeRange: AgeInYearsAt(start of MeasurementPeriod) >= 18 and AgeInYearsAt(start of MeasurementPeriod) < 85

define PatientHTNconditionsList: [Condition: "Diagnosis: Essential Hypertension"]
define PatientHTNdxInMP: PatientHTNconditionsList C where
							C.verificationStatusString = 'confirmed' and
							C.clinicalStatusString = 'active' and
							C.onsetDateTime during Interval[start of MeasurementPeriod, start of MeasurementPeriod + 6 months]
define PatientHTNdxPriorToMP: PatientHTNconditionsList C where
								C.verificationStatusString = 'confirmed' and
								C.clinicalStatusString = 'active' and
								C.onsetDateTime before start of MeasurementPeriod and
								Interval[C.onsetDateTime, C.abatementDateTime] overlaps MeasurementPeriod
define PatientHTNinMP: PatientHTNdxInMP union PatientHTNdxPriorToMP
define HasHTNinMP: exists( PatientHTNinMP )

define PatientEncountersBeforeMPend: [Encounter] E where E.periodStart before end of MeasurementPeriod
define PatientAmbEncountersInMP:
					PatientEncountersBeforeMPend E where
								Interval[E.periodStart, E.periodEnd] during MeasurementPeriod and
								E.status.value = 'finsihed' and
								// EDIT: changed E.type ET where ET.coding ETC where to line below
								exists E.type ET where exists ET.coding ETC where
									ETC.code in "Encounter, Performed: Office Visit" or
									ETC.code in "Encounter, Performed: Face-to-Face Interaction" or
									ETC.code in "Encounter, Performed: Preventive Care Services-Established Office Visit, 18 and Up" or
									ETC.code in "Encounter, Performed: Preventive Care Services-Initial Office Visit, 18 and Up" or
									ETC.code in "Encounter, Performed: Home Healthcare Services" or
									ETC.code in "Encounter, Performed: Annual Wellness Visit"
define HasAmbEncounterInMP: exists( PatientAmbEncountersInMP )

define PatientConditionsBeforeMPend: [Condition] C where C.onsetDateTime before end of MeasurementPeriod
define PatientDxExclusionsInMP: PatientConditionsBeforeMPend C where
									C.verificationStatusString = 'confirmed' and
									C.clinicalStatusString = 'active' and
									(C.code in "Diagnosis: Pregnancy" or
									 C.code in "Diagnosis: End Stage Renal Disease" or
									 C.code in "Diagnosis: Chronic Kidney Disease, Stage 5") and
									Interval[C.onsetDateTime, C.abatementDateTime] overlaps MeasurementPeriod
define HasDxExclusionInMP: exists( PatientDxExclusionsInMP )

define PatientProceduresInMP: [Procedure] P where P.performedPeriodStart before end of MeasurementPeriod
define PatientProcExclusionsInMP: PatientProceduresInMP P where
									P.status in {'completed', 'in-progress'} and
								    (P.code in "Procedure, Performed: Vascular Access for Dialysis" or
									 P.code in "Procedure, Performed: Kidney Transplant" or
									 P.code in "Procedure, Performed: Dialysis Services" or
									 P.code in "Intervention, Performed: Other Services Related to Dialysis" or
									 P.code in "Intervention, Performed: Dialysis Education")
define HasProcExclusionInMP: exists( PatientProcExclusionsInMP )

define PatientESRDencBeforeMPend: PatientEncountersBeforeMPend E where
									E.status = 'finished' and
									E.type ET where
										ET.coding ETC where
											ETC.code in "Encounter, Performed: ESRD Monthly Outpatient Services"
define HasEncExclusionInMP: exists( PatientEncExlusionsInMP )

define PatientAdultOPVinMP: PatientEncountersBeforeMPend E where
										E.status = 'finished' and
										Interval[E.periodStart, E.periodEnd] during MeasurementPeriod and
										E.type ET where
											ET.coding ETC where
												ETC.code in "Encounter, Performed: Adult Outpatient Visit"


define PatientSBPinMP: [Observation: "Physical Exam, Performed: Systolic Blood Pressure"] O where
								O.effectivePeriodStart during MeasurementPeriod
define PatientSBPresultInMP: PatientSBPinMP SBP
									where SBP.status in {'final', 'amended'} and
										  SBP.valueQuantity is not null

define PatientDBPinMP: [Observation: "Physical Exam, Performed: Diastolic Blood Pressure"] O where
								O.effectivePeriodStart during MeasurementPeriod
define PatientDBPresultInMP: PatientDBPinMP DBP
									where DBP.status in {'final', 'amended'} and
										  DBP.valueQuantity is not null

define PatientNumeratorEncounters:
			PatientAdultOPVinMP OPV
				with PatientHTNinMP HTN such that Interval[OPV.periodStart, OPV.periodEnd] overlaps Interval[HTN.onsetDateTime, HTN.abatementDateTime]
				with PatientDBPresultInMP DBP such that Interval[OPV.periodStart, OPV.periodEnd] overlaps Interval[DBP.effectivePeriodStart, DBP.effectivePeriodEnd]
				with PatientSBPresultInMP SBP such that Interval[OPV.periodStart, OPV.periodEnd] overlaps Interval[SBP.effectivePeriodStart, SBP.effectivePeriodEnd]
define HasNumeratorEncounters: exists( PatientNumeratorEncounters )
define LastPNE: Last( PatientNumeratorEncounters PNE sort by PNE.periodStart )

define PatientNumeratorDBP:
			 PatientDBPresultInMP DBP where
					Interval[DBP.effectivePeriodStart, DBP.effectivePeriodEnd] during Interval[LastPNE.periodStart, LastPNE.periodEnd] and
					DBP.valueQuantity < 90 'mm[Hg]'
define HasNumeratorDBP: exists( PatientNumeratorDBP )


define PatientNumeratorSBP:
			 PatientSBPresultInMP SBP where
					Interval[SBP.effectivePeriodStart, SBP.effectivePeriodEnd] during Interval[LastPNE.periodStart, LastPNE.periodEnd] and
					DBP.valueQuantity < 140 'mm[Hg]'
define HasNumeratorSBP: exists( PatientNumeratorSBP )


define InInitialPopulation: InAgeRange and
								HasHTNinMP and
								HasAmbEncounterInMP

define InDenominator: InInitialPopulation

define InDenominatorExclusion: InDenominator and
									(HasDxExclusionInMP or
									 HasProcExclusionInMP or
									 HasEncExclusionInMP)

define InNumerator: InDenominator and not InDenominatorExclusion and
						HasNumeratorEncounters and
						HasNumeratorDBP and
						HasNumeratorSBP


context Population

define InitialPopulationList: Patient P where InInitialPopulation
define DenominatorList: InitialPopulationList
define DenominatorExclusionList: Patient P where InDenominatorExclusion
define EffectiveDenominatorList: DenominatorList except DenominatorExclusionList
define NumeratorList: Patient P where InNumerator
define MeasureScore: 100 * ( Count(NumeratorList) / (if exists(EffectiveDenominatorList)
													 then Count(EffectiveDenominatorList)
													 else 1) )
