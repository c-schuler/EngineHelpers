package com.mmi.cql;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by Christopher on 1/8/2017.
 */
public class ResourcesAndAttributes {

    // { Resource -> [ attribute1, attribute2, ... ], ... }
    private HashMap<String, List<String> > resourcesAndAttributes;
    private String cql;

    private HashMap<String, String> expressions;
    private HashMap<String, String> retrieves;
    private HashMap<String, String> returnTypes;

    private final String ATTRIBUTE_REGEX = "\\w+\\..[\\.|\\w|\"]*";

    public ResourcesAndAttributes(String cql) {
        this.cql = cql;
        this.resourcesAndAttributes = new HashMap<>();
    }

    public ResourcesAndAttributes(File f) {
        this.cql = StringOperations.getFileAsString(f);
        this.resourcesAndAttributes = new HashMap<>();
    }

    public HashMap<String, List<String> > getMap() {
        return resourcesAndAttributes;
    }

    private void clean() {
        cql = StringOperations.removeComments(cql);
        cql = StringOperations.trimHead(cql);
    }

    private void initMap() {
        for (String key : retrieves.keySet()) {
            if (!resourcesAndAttributes.containsKey(retrieves.get(key)))
                resourcesAndAttributes.put(retrieves.get(key), new ArrayList<>());
        }
        resourcesAndAttributes.put("Patient", new ArrayList<>());
    }

    private void addAttribute(String resource, String attribute) {
        List<String> attributes = resourcesAndAttributes.get(resource);
        if (attribute.contains(".value")) {
            attribute = attribute.replace(".value", "");
        }
        if (!attributes.contains(attribute)) {
            attributes.add(attribute.replace(".value", ""));
        }
        resourcesAndAttributes.put(resource, attributes);
    }

    private void processRetrieve(String content, String resource) {
        Pattern p = Pattern.compile(ATTRIBUTE_REGEX);
        Matcher m = p.matcher(content);
        while (m.find()) {
            String attribute = m.group().replace(m.group().split("\\.")[0] + ".", "");
            addAttribute(resource, attribute);
        }
    }

    private void resolveAliasWithAttribute(String alias, String attribute, String key, String content) {
        if (returnTypes.containsKey(alias)) {
            addAttribute(returnTypes.get(alias), attribute);
            return;
        }

        alias = key.split("\\.")[0];
        attribute = key.replace(alias + ".", "") + "." + attribute;
        Pattern p = Pattern.compile("(\\w|\\.|\")+\\s+" + alias + "[^\\.]");
        Matcher m = p.matcher(content);
        if (m.find()) {
            alias = m.group().split(" ")[0];
        }
        resolveAliasWithAttribute(alias, attribute, alias, content);
    }

    private void processExpressionRef(String name, String content) {
        Pattern p = Pattern.compile(ATTRIBUTE_REGEX);
        Matcher m = p.matcher(content);
        while (m.find()) {
            String alias = m.group().split("\\.")[0];
            String attribute = m.group().replace(alias + ".", "");

            // ExpressionRef as alias
            if (expressions.keySet().contains(alias)) {
                addAttribute(returnTypes.get(alias), attribute);
            }
            // Direct access to Patient resource - TODO: Population?
            else if (alias.equals("Patient")) {
                addAttribute("Patient", attribute);
            }
            // ExpressionRef with alias
            else {
                Pattern pp = Pattern.compile("(\\w|\\.|\")+\\s+" + alias + "[^\\.]"); // ExpressionRef Regex
                Matcher mm = pp.matcher(expressions.get(name));
                if (mm.find()) {
                    String key = mm.group().trim().split(" ")[0];
                    if (key.contains(".")) { // alias may be a resource with attribute(s)
                        resolveAliasWithAttribute(key, attribute, key, content);
                    }
                    else if (returnTypes.containsKey(key) && returnTypes.get(key) != null)
                        addAttribute(returnTypes.get(key), attribute);
                }
            }
        }
    }

    private void processExpressions() {
        for (String name : expressions.keySet()) {
            if (retrieves.keySet().contains(name))
                processRetrieve(expressions.get(name), retrieves.get(name));

            else { // ExpressionRef
                processExpressionRef(name, expressions.get(name));
            }
        }
    }

    public void populateMap() {
        clean();
        retrieves = StringOperations.getRetrieves(cql);
        initMap();
        expressions = StringOperations.getExpressions(cql);
        returnTypes = StringOperations.getExpressionReturnTypes(cql);
        processExpressions();
    }

    public void printMap() {
        StringBuilder result = new StringBuilder();
        for (String resource : resourcesAndAttributes.keySet()) {
            result.append("Resource Type: ");
            result.append(resource.trim());
            result.append("\nAttributes: ");

            int count = 0;
            List<String> attributes = resourcesAndAttributes.get(resource);
            for (String attribute : attributes) {
                result.append(attribute);
                result.append(++count >= attributes.size() ? "" : ", ");
            }
            result.append("\n");
        }
        System.out.println(result.toString());
    }
}
