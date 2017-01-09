package com.mmi.cql;

import org.junit.Assert;
import org.junit.Test;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Created by Christopher on 1/8/2017.
 */
public class ResourceAndAttributeTests {

    @Test
    public void CMS179v3Test() {
        Path path = Paths.get("src/main/resources/CMS179v3_CQM.cql").toAbsolutePath();
        ResourcesAndAttributes rANDa = new ResourcesAndAttributes(new File(path.toString()));
        rANDa.populateMap();

        Assert.assertEquals(rANDa.getMap().get("Condition").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("onsetDateTime"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("abatementDate"));

        Assert.assertEquals(rANDa.getMap().get("MedicationAdministration").size(), 1);
        Assert.assertTrue(rANDa.getMap().get("MedicationAdministration").contains("effectiveTimePeriod"));

        Assert.assertEquals(rANDa.getMap().get("Observation").size(), 4);
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("resultDate"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("appliesDateTime"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("valueQuantity"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("distanceFromMidpoint"));

        Assert.assertTrue(rANDa.getMap().get("Patient").isEmpty());

        Assert.assertEquals(rANDa.getMap().get("Encounter").size(), 1);
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("period"));
    }

    @Test
    public void ColorectalCancerTest() {
        Path path = Paths.get("src/main/resources/gFHIRDMColorectalCancer.cql").toAbsolutePath();
        ResourcesAndAttributes rANDa = new ResourcesAndAttributes(new File(path.toString()));
        rANDa.populateMap();

        Assert.assertEquals(rANDa.getMap().get("Condition").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("clinicalStatus"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("verificationStatus"));

        Assert.assertEquals(rANDa.getMap().get("Observation").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("effectiveDateTime"));

        Assert.assertEquals(rANDa.getMap().get("Procedure").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("Procedure").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("Procedure").contains("performedPeriod.\"end\""));

        Assert.assertTrue(rANDa.getMap().get("Patient").isEmpty());
    }

    @Test
    public void ACO28Test() {
        Path path = Paths.get("src/main/resources/ACO28.cql").toAbsolutePath();
        ResourcesAndAttributes rANDa = new ResourcesAndAttributes(new File(path.toString()));
        rANDa.populateMap();

        Assert.assertEquals(rANDa.getMap().get("Condition").size(), 5);
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("clinicalStatusString"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("verificationStatusString"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("onsetDateTime"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("abatementDateTime"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("code"));

        Assert.assertEquals(rANDa.getMap().get("Observation").size(), 6);
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("valueQuantity"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("effectivePeriodStart"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("effectivePeriodEnd"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("periodStart"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("periodEnd"));

        Assert.assertEquals(rANDa.getMap().get("Procedure").size(), 3);
        Assert.assertTrue(rANDa.getMap().get("Procedure").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("Procedure").contains("performedPeriodStart"));
        Assert.assertTrue(rANDa.getMap().get("Procedure").contains("code"));

        Assert.assertTrue(rANDa.getMap().get("Patient").isEmpty());

        Assert.assertEquals(rANDa.getMap().get("Encounter").size(), 6);
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("periodStart"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("periodEnd"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("type"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("type.coding"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("type.coding.code"));
    }

    @Test
    public void EyeExamTest() {
        Path path = Paths.get("src/main/resources/gFHIRDMEyeExam.cql").toAbsolutePath();
        ResourcesAndAttributes rANDa = new ResourcesAndAttributes(new File(path.toString()));
        rANDa.populateMap();

        Assert.assertEquals(rANDa.getMap().get("Condition").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("clinicalStatus"));
        Assert.assertTrue(rANDa.getMap().get("Condition").contains("verificationStatus"));

        Assert.assertEquals(rANDa.getMap().get("Observation").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("valueCodeableConcept.coding"));
        Assert.assertTrue(rANDa.getMap().get("Observation").contains("effectiveDateTime"));

        Assert.assertEquals(rANDa.getMap().get("ProcedureRequest").size(), 2);
        Assert.assertTrue(rANDa.getMap().get("ProcedureRequest").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("ProcedureRequest").contains("scheduledDateTime"));

        Assert.assertTrue(rANDa.getMap().get("Patient").isEmpty());

        Assert.assertEquals(rANDa.getMap().get("Encounter").size(), 4);
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("classElement"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("status"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("participantCode"));
        Assert.assertTrue(rANDa.getMap().get("Encounter").contains("periodstart"));
    }
}
