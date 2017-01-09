library CMS179 version '2'

// Warfarin time in therapeutic range

using QUICK

valueset "Flutter Diagnosis": '2.16.840.1.113883.3.117.1.7.1.202'
valueset "Warfarin Medication": '2.16.840.1.113883.3.117.1.7.1.232'
valueset "Face-to-face Encounter": '2.16.840.1.113883.3.464.1003.101.12.1048'
valueset "Office Visit": '2.16.840.1.113883.3.464.1003.101.12.1001'
valueset "Valvular Heart Disease": '2.16.840.1.113883.3.464.1003.104.12.1017'
valueset "INR Lab Result": '2.16.840.1.113883.3.117.1.7.1.213'

parameter MeasurementPeriod default Interval[DateTime(2013, 1, 1, 0, 0, 0, 0), DateTime(2014, 1, 1, 0, 0, 0, 0))

context Patient

define FlutterDiagnoses: [Condition: "Flutter Diagnosis"]
define WarfarinMedications: [MedicationAdministration: "Warfarin Medication"]
define FaceToFaceEncounters: [Encounter: "Face-to-face Encounter"]
define OfficeVisitEncounters: [Encounter: "Office Visit"]
define ValvularHeartDiseaseDiagnoses: [Condition: "Valvular Heart Disease"]
define INRLabResults: [Observation: "INR Lab Result"]

define InDemographic:
	AgeInYearsAt(start of MeasurementPeriod) >= 18

define InpatientEncounters: FaceToFaceEncounters union OfficeVisitEncounters

define ActiveFlutterDiagnoses:
	FlutterDiagnoses F where Interval[F.onsetDateTime, F.abatementDate] overlaps before MeasurementPeriod
define ActiveValvularHeartDiseaseDiagnoses:
	ValvularHeartDiseaseDiagnoses D where Interval[D.onsetDateTime, D.abatementDate] overlaps before MeasurementPeriod

define LookbackInterval:
	Interval[start of MeasurementPeriod - 200 days, start of MeasurementPeriod]

define ActiveWarfarinDuringLookback:
	WarfarinMedications M where M.effectiveTimePeriod overlaps LookbackInterval

define WarfarinUsageIntervals:
	collapse
		ActiveWarfarinDuringLookback M
			return M.effectiveTimePeriod intersect LookbackInterval

// getting number of days of warfarin use
define WarfarinUsage:
	Sum(WarfarinUsageIntervals I return duration in days of I)

// Here we start to narrow our focus:
// Don't include results when patient is hospitalized for more than 23 hours
define INROutpatientLabResult:
	INRLabResults R
		where not exists (InpatientEncounters E where duration in hours of E.period > 23 and R.appliesDateTime occurs during E.period)

// Get results that are within the INR
define INRResultsByDay:
	INROutpatientLabResult L
		where L.valueQuantity.value > 0.8 // TODO: Units?
		return
			Tuple
			{
				resultDate: date from L.appliesDateTime,
				result: if L.valueQuantity.value > 10.0 then 10.0 else L.valueQuantity.value, // TODO: Units?
				// how far off target INR?
				distanceFromMidpoint: Abs(2.5 - L.valueQuantity.value) // TODO: Units?
			}

// Get record with INR closest to target if more than 1 record exists on a given day
define INRResultsPerDay:
	(
			(distinct INRResultsByDay X return X.resultDate) D
				return First(INRResultsByDay R where R.resultDate = D sort by R.distanceFromMidpoint)
		) X
	sort by X.resultDate

// TTR
define TherapeuticRange:
	Interval[2.0, 3.0] // TODO: Units?

// Create a tuple with information for an interval between results
define INRIntervals:
	(INRResultsPerDay S return Tuple { startResult: S, endResult: First(INRResultsPerDay E where S.resultDate > E.resultDate) }) X
		return
			Tuple
			{
				startDate: X.startResult.resultDate,
				endDate: X.endResult.resultDate,
				resultDays: days between X.startResult.resultDate and X.endResult.resultDate,
				resultDifference: X.endResult.result - X.startResult.result,
				resultsWithinBounds: X.startResult.result in TherapeuticRange and X.endResult.result in TherapeuticRange,
				boundedDifference:
					if X.endResult.result >= X.startResult.result
						then
						(
							// this seems overly redundant...
							if X.startResult.result > end of TherapeuticRange or X.endResult.result < start of TherapeuticRange
								then null
								else Min({X.endResult.result, end of TherapeuticRange}) - Max({X.startResult.result, start of TherapeuticRange})
						)
						else
						(
							if X.endResult.result > end of TherapeuticRange or X.startResult.result < start of TherapeuticRange
								then null
								else Min({X.startResult.result, end of TherapeuticRange}) - Max({X.endResult.result, start of TherapeuticRange})
						),
				isValid: days between X.startResult.resultDate and X.endResult.resultDate <= 56
			}

// Number of days where the results are within TTR is only thing new here
define TherapeuticDays:
	INRIntervals I
		return
			Tuple
			{
				startDate: I.startDate,
				endDate : I.endDate,
				isValid : I.isValid,
				resultDays : I.resultDays,
				daysInRange :
					if I.resultsWithinBounds
						then I.resultDays
						else Coalesce(I.resultDays * Abs(I.boundedDifference / (if I.resultDays = 0 then null else I.resultDays)), 0)
			}

// Gives TTR
define TherapeuticTimeInRange:
	Round(100 * (Sum(TherapeuticDays X return X.daysInRange) / Sum(TherapeuticDays X return X.resultDays)))

define NumberOfValidIntervals:
	Count(TherapeuticDays D where D.isValid)

define HasValidIntervals:
	NumberOfValidIntervals >= 2

define InitialPopulation:
	InDemographic
		and exists (InpatientEncounters)
		and exists (ActiveFlutterDiagnoses)
		and WarfarinUsage >= 180
		and not exists (ActiveValvularHeartDiseaseDiagnoses)

define MeasurePopulation:
	HasValidIntervals

define MeasureObservation:
	TherapeuticTimeInRange

context Population

define MeasureScore: Avg(MeasureObservation)
