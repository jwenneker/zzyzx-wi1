<%@  page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %><%
/*
 * ====================================================================
 * Project:     opencrx, http://www.opencrx.org/
 * Name:        $Id: ImportPropertiesFromXLS.jsp,v 1.8 2011/07/09 18:42:32 wfro Exp $
 * Description: import properties from Excel Sheet
 * Revision:    $Revision: 1.8 $
 * Owner:       CRIXP Corp., Switzerland, http://www.crixp.com
 * Date:        $Date: 2011/07/09 18:42:32 $
 * ====================================================================
 *
 * This software is published under the BSD license
 * as listed below.
 *
 * Copyright (c) 2009-2011, CRIXP Corp., Switzerland
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * * Neither the name of CRIXP Corp. nor the names of the contributors
 * to openCRX may be used to endorse or promote products derived
 * from this software without specific prior written permission
 *
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 * CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * ------------------
 *
 * This product includes software developed by the Apache Software
 * Foundation (http://www.apache.org/).
 *
 * This product includes software developed by contributors to
 * openMDX (http://www.openmdx.org/)
 */
%><%@ page session="true" import="
java.util.*,
java.io.*,
java.text.*,
java.math.*,
java.net.URL,
java.net.URLEncoder,
java.net.MalformedURLException,
java.io.UnsupportedEncodingException,
javax.xml.datatype.*,
org.openmdx.kernel.id.cci.*,
org.openmdx.kernel.id.*,
org.opencrx.kernel.portal.*,
org.openmdx.base.accessor.jmi.cci.*,
org.openmdx.base.exception.*,
org.openmdx.portal.servlet.*,
org.openmdx.portal.servlet.action.*,
org.openmdx.portal.servlet.attribute.*,
org.openmdx.portal.servlet.view.*,
org.openmdx.portal.servlet.texts.*,
org.openmdx.portal.servlet.control.*,
org.openmdx.portal.servlet.reports.*,
org.openmdx.portal.servlet.wizards.*,
org.openmdx.base.naming.*,
org.openmdx.base.query.*,
org.openmdx.base.exception.*,
org.openmdx.kernel.log.*,
org.openmdx.uses.org.apache.commons.fileupload.*,
org.apache.poi.hssf.usermodel.*,
org.apache.poi.hssf.util.*,
org.apache.poi.poifs.filesystem.POIFSFileSystem
" %>
<%!

    /* the following properties are modelled */
    final String PROPERTY_DTYPE_STRING = "StringProperty";
    final String PROPERTY_DTYPE_DECIMAL = "DecimalProperty";
    final String PROPERTY_DTYPE_INTEGER = "IntegerProperty";
    final String PROPERTY_DTYPE_BOOLEAN = "BooleanProperty";
    final String PROPERTY_DTYPE_DATE = "DateProperty";
    final String PROPERTY_DTYPE_DATETIME = "DateTimeProperty";
    final String PROPERTY_DTYPE_URI = "UriProperty";
    final String PROPERTY_DTYPE_REFERENCE = "ReferenceProperty";

    final String ATTR_PROPERTY_DTYPE = "Property_dtype";
    final String ATTR_PROPERTY_NAME = "Property_name";
    final String ATTR_PROPERTY_DESCRIPTION = "Property_description";
    final String ATTR_PROPERTY_VALUE = "Property_value";

    boolean containsHeader_PropertySet_name = false;
    final String ATTR_PROPERTYSET_NAME = "PropertySet_name";
    final String ATTR_PROPERTYSET_DESCRIPTION = "PropertySet_description";
    final String ATTR_PROPERTYSET_VALUE = "PropertySet_value";

    boolean containsHeader_PropertyConfigurationType_name = false;
    final String ATTR_PRODUCTCONFIGURATIONTYPE_NAME = "ProductConfigurationType_name";
    final String ATTR_PRODUCTCONFIGURATIONTYPE_DESCRIPTION = "ProductConfigurationType_description";
    final String ATTR_PRODUCTCONFIGURATIONTYPE_VALIDFROM = "ProductConfigurationType_validFrom";
    final String ATTR_PRODUCTCONFIGURATIONTYPE_VALIDTO = "ProductConfigurationType_validTo";
    final String ATTR_PRODUCTCONFIGURATIONTYPE_ISDEFAULT = "ProductConfigurationType_isDefault";

    boolean containsHeader_PropertyConfigurationTypeSet_name = false;
    final String ATTR_PRODUCTCONFIGURATIONTYPESET_NAME = "ProductConfigurationTypeSet_name";
    final String ATTR_PRODUCTCONFIGURATIONTYPESET_DESCRIPTION = "ProductConfigurationTypeSet_description";

    public String getUidAsString(
    ) throws ServiceException {
    	return org.opencrx.kernel.backend.Base.getInstance().getUidAsString();
    }

    public boolean isSupportedDtypeValue(
        String property_dtype,
        HSSFCell property_value
    ) {
        return (
            property_dtype != null &&
            (
                property_value == null ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_STRING) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_STRING) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_DECIMAL) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_NUMERIC && !HSSFDateUtil.isCellDateFormatted(property_value)) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_INTEGER) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_NUMERIC && !HSSFDateUtil.isCellDateFormatted(property_value)) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_BOOLEAN) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_DATETIME) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_NUMERIC && HSSFDateUtil.isCellDateFormatted(property_value)) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_DATE) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_NUMERIC && HSSFDateUtil.isCellDateFormatted(property_value)) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_REFERENCE) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_STRING) ||
                ((property_dtype.compareTo(PROPERTY_DTYPE_URI) == 0) && property_value.getCellType() == HSSFCell.CELL_TYPE_STRING)
            )
        );
    }

    public boolean updateProductConfigurationType(
        org.opencrx.kernel.product1.jmi1.ProductConfigurationType productConfigurationType,
        Map valueMap,
        javax.jdo.PersistenceManager pm
    ) {
        HSSFCell cell = null;
        boolean updated = false;
        try {
            // validFrom
            pm.currentTransaction().begin();
            if (valueMap.get(ATTR_PRODUCTCONFIGURATIONTYPE_VALIDFROM) != null) {
                cell = (HSSFCell)valueMap.get(ATTR_PRODUCTCONFIGURATIONTYPE_VALIDFROM);
                if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC && HSSFDateUtil.isCellDateFormatted(cell)) {
                    productConfigurationType.setValidFrom(HSSFDateUtil.getJavaDate(cell.getNumericCellValue()));
                    updated = true;
                }
            }
            pm.currentTransaction().commit();
        } catch (Exception e) {
            new ServiceException(e).log();
            try {
                pm.currentTransaction().rollback();
            } catch(Exception e1) {}
        }

        try {
            // validTo
            pm.currentTransaction().begin();
            if (valueMap.get(ATTR_PRODUCTCONFIGURATIONTYPE_VALIDTO) != null) {
                cell = (HSSFCell)valueMap.get(ATTR_PRODUCTCONFIGURATIONTYPE_VALIDTO);
                if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC && HSSFDateUtil.isCellDateFormatted(cell)) {
                    productConfigurationType.setValidTo(HSSFDateUtil.getJavaDate(cell.getNumericCellValue()));
                    updated = true;
                }
            }
            pm.currentTransaction().commit();
        } catch (Exception e) {
            new ServiceException(e).log();
            try {
                pm.currentTransaction().rollback();
            } catch(Exception e1) {}
        }

        try {
            // isDefault
            pm.currentTransaction().begin();
            if (valueMap.get(ATTR_PRODUCTCONFIGURATIONTYPE_ISDEFAULT) != null) {
                cell = (HSSFCell)valueMap.get(ATTR_PRODUCTCONFIGURATIONTYPE_ISDEFAULT);
                if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
                    productConfigurationType.setDefault(new Boolean(cell.getBooleanCellValue()));
                    updated = true;
                }
            }
            pm.currentTransaction().commit();
        } catch (Exception e) {
            new ServiceException(e).log();
            try {
                pm.currentTransaction().rollback();
            } catch(Exception e1) {}
        }

        return updated;
    }

    public org.opencrx.kernel.base.jmi1.Property createOrUpdatePropertyOfPropertySet(
        org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet prodConfTypeSet,
        String productConfigurationTypeSet_name,
        String productConfigurationTypeSet_description,
        org.opencrx.kernel.product1.jmi1.ProductConfigurationType prodConfType,
        String productConfigurationType_name,
        String productConfigurationType_description,
        org.opencrx.kernel.generic.jmi1.CrxObject crxObject,
        org.opencrx.kernel.generic.jmi1.PropertySet propSet,
        String propertySet_name,
        String propertySet_description,
        String property_dtype,
        String property_name,
        String property_description,
        HSSFCell property_value,
        org.opencrx.kernel.product1.jmi1.Segment productSegment,
        org.opencrx.kernel.product1.jmi1.Product1Package productPkg,
        org.opencrx.kernel.base.jmi1.BasePackage basePkg,
        org.opencrx.kernel.generic.jmi1.GenericPackage genericPkg,
        javax.jdo.PersistenceManager pm,
        ApplicationContext app
    ) {
        org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet productConfigurationTypeSet = prodConfTypeSet;
        org.opencrx.kernel.product1.jmi1.ProductConfigurationType productConfigurationType = prodConfType;
        org.opencrx.kernel.generic.jmi1.PropertySet propertySet = propSet;
        org.opencrx.kernel.base.jmi1.Property property = null;
        if (
            prodConfTypeSet != null || productConfigurationTypeSet_name != null ||
            prodConfType != null || productConfigurationType_name != null
        ) {
            if (
                productConfigurationTypeSet == null &&
                productConfigurationTypeSet_name != null && productConfigurationTypeSet_name.length() > 0
            ) {
                // try to locate productConfigurationTypeSet with respective name (or create new productConfigurationTypeSet)
                org.opencrx.kernel.product1.cci2.ProductConfigurationTypeSetQuery productConfigurationTypeSetFilter = productPkg.createProductConfigurationTypeSetQuery();
                productConfigurationTypeSetFilter.name().equalTo(productConfigurationTypeSet_name);
                try {
                    pm.currentTransaction().begin();
                    Iterator pcts = productSegment.getConfigurationTypeSet(productConfigurationTypeSetFilter).iterator();
                    if (pcts.hasNext()) {
                        productConfigurationTypeSet = (org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet)pcts.next();
                    } else {
                        // create new ProductConfigurationTypeSet
                        productConfigurationTypeSet = productPkg.getProductConfigurationTypeSet().createProductConfigurationTypeSet();
                        productConfigurationTypeSet.refInitialize(false, false);
                        productConfigurationTypeSet.setName(productConfigurationTypeSet_name);
                        productSegment.addConfigurationTypeSet(
                            false,
                            getUidAsString(),
                            productConfigurationTypeSet
                        );
                    }
                    productConfigurationTypeSet.setDescription(productConfigurationTypeSet_description);
                    pm.currentTransaction().commit();
                    //System.out.println("productConfigurationTypeSet found/committed name=" + productConfigurationTypeSet.getName());
                } catch (Exception e) {
                    new ServiceException(e).log();
                    try {
                        pm.currentTransaction().rollback();
                    } catch(Exception e1) {}
                }
            }
            if (
                productConfigurationTypeSet != null &&
                productConfigurationType == null &&
                productConfigurationType_name != null && productConfigurationType_name.length() > 0
            ) {
                // try to locate productConfigurationType with respective name (or create new productConfigurationType)
                org.opencrx.kernel.product1.cci2.ProductConfigurationTypeQuery productConfigurationTypeFilter = productPkg.createProductConfigurationTypeQuery();
                productConfigurationTypeFilter.name().equalTo(productConfigurationType_name);
                try {
                    pm.currentTransaction().begin();
                    Iterator pct = productConfigurationTypeSet.getConfigurationType(productConfigurationTypeFilter).iterator();
                    if (pct.hasNext()) {
                        productConfigurationType = (org.opencrx.kernel.product1.jmi1.ProductConfigurationType)pct.next();
                    } else {
                        // create new ProductConfigurationType
                        productConfigurationType = productPkg.getProductConfigurationType().createProductConfigurationType();
                        productConfigurationType.refInitialize(false, false);
                        productConfigurationType.setName(productConfigurationType_name);
                        productConfigurationTypeSet.addConfigurationType(
                            false,
                            getUidAsString(),
                            productConfigurationType
                        );
                    }
                    productConfigurationType.setDescription(productConfigurationType_description);
                    pm.currentTransaction().commit();
                    //System.out.println("productConfigurationType found/committed name=" + productConfigurationTypeSet.getName());
                } catch (Exception e) {
                    new ServiceException(e).log();
                    try {
                        pm.currentTransaction().rollback();
                    } catch(Exception e1) {}
                }
            }
        } else if (crxObject != null) {
            // try to locate PropertySet with same parent and name (or create new PropertySet)
            org.opencrx.kernel.generic.cci2.PropertySetQuery propertySetFilter = genericPkg.createPropertySetQuery();
            propertySetFilter.name().equalTo(propertySet_name);
            try {
                pm.currentTransaction().begin();
                Iterator ps = crxObject.getPropertySet(propertySetFilter).iterator();
                if (ps.hasNext()) {
                    propertySet = (org.opencrx.kernel.generic.jmi1.PropertySet)ps.next();
                } else {
                    // create new PropertySet
                    propertySet = genericPkg.getPropertySet().createPropertySet();
                    propertySet.refInitialize(false, false);
                    propertySet.setName(propertySet_name);
                    crxObject.addPropertySet(
                        false,
                        getUidAsString(),
                        propertySet
                    );
                }
                propertySet.setDescription(propertySet_description);
                pm.currentTransaction().commit();
            } catch (Exception e) {
                new ServiceException(e).log();
                try {
                    pm.currentTransaction().rollback();
                } catch(Exception e1) {}
            }
        }
        if (
            (propertySet != null || productConfigurationType != null) &&
            property_dtype != null && property_dtype.length() > 0 &&
            property_name != null && property_name.length() > 0
        ) {
            // try to locate property with same parent and name (or create new property)
            org.opencrx.kernel.base.cci2.PropertyQuery propertyFilter = basePkg.createPropertyQuery();
            propertyFilter.name().equalTo(property_name);
            Iterator p = null;
            if (productConfigurationType != null) {
                p = productConfigurationType.getProperty(propertyFilter).iterator();
            } else {
                p = propertySet.getProperty(propertyFilter).iterator();
            }
            try {
                while(p.hasNext() && property == null) {
                    property = (org.opencrx.kernel.base.jmi1.Property)p.next();
                    if (!(
                        (property instanceof org.opencrx.kernel.base.jmi1.StringProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_STRING) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.DecimalProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_DECIMAL) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.IntegerProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_INTEGER) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.BooleanProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_BOOLEAN) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.DateTimeProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_DATETIME) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.DateProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_DATE) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.ReferenceProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_REFERENCE) == 0) ||
                        (property instanceof org.opencrx.kernel.base.jmi1.UriProperty) && (property_dtype.compareTo(PROPERTY_DTYPE_URI) == 0)
                    )) {
                        property = null;
                    }
                }

                pm.currentTransaction().begin();

                if (property_dtype.compareTo(PROPERTY_DTYPE_STRING) == 0) {
                    if (property == null) {
                        // create new StringProperty
                        property = basePkg.getStringProperty().createStringProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        ((org.opencrx.kernel.base.jmi1.StringProperty)property).setStringValue(property_value != null ? property_value.getStringCellValue().trim() : null);
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_DECIMAL) == 0) {
                    if (property == null) {
                        // create new DecimalProperty
                        property = basePkg.getDecimalProperty().createDecimalProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        ((org.opencrx.kernel.base.jmi1.DecimalProperty)property).setDecimalValue(property_value != null ? new BigDecimal(property_value.getNumericCellValue()) : null);
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_INTEGER) == 0) {
                    if (property == null) {
                        // create new IntegerProperty
                        property = basePkg.getIntegerProperty().createIntegerProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        ((org.opencrx.kernel.base.jmi1.IntegerProperty)property).setIntegerValue(property_value != null ? (new BigDecimal(property_value.getNumericCellValue())).intValue() : null);
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_BOOLEAN) == 0) {
                    if (property == null) {
                        // create new BooleanProperty
                        property = basePkg.getBooleanProperty().createBooleanProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        ((org.opencrx.kernel.base.jmi1.BooleanProperty)property).setBooleanValue(property_value != null ? property_value.getBooleanCellValue() : null);
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_DATETIME) == 0) {
                    if (property == null) {
                        // create new DateTimeProperty
                        property = basePkg.getDateTimeProperty().createDateTimeProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        ((org.opencrx.kernel.base.jmi1.DateTimeProperty)property).setDateTimeValue(property_value != null ? HSSFDateUtil.getJavaDate(property_value.getNumericCellValue()) : null);
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_DATE) == 0) {
                    if (property == null) {
                        // create new DateTimeProperty
                        property = basePkg.getDateProperty().createDateProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        if (property_value != null) {
                            TimeZone timezone = TimeZone.getTimeZone(app.getCurrentTimeZone());
                            SimpleDateFormat dateonlyf = new SimpleDateFormat("yyyyMMdd", app.getCurrentLocale()); dateonlyf.setTimeZone(timezone);
                            String date =
    				        	dateonlyf.format(HSSFDateUtil.getJavaDate(property_value.getNumericCellValue())).substring(0, 8);
                            XMLGregorianCalendar cal = org.w3c.spi2.Datatypes.create(
                                XMLGregorianCalendar.class,
                                date
                            );
                            ((org.opencrx.kernel.base.jmi1.DateProperty)property).setDateValue(cal);
                        } else {
                            ((org.opencrx.kernel.base.jmi1.DateProperty)property).setDateValue(null);
                        }
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_REFERENCE) == 0) {
                    if (property == null) {
                        // create new ReferenceProperty
                        property = basePkg.getReferenceProperty().createReferenceProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        org.openmdx.base.jmi1.BasicObject basicObject = null;
                        if (property_value != null) {
                            try {
                               String xri = property_value.getStringCellValue().trim();
                               basicObject = (org.openmdx.base.jmi1.BasicObject)pm.getObjectById(new Path(xri));
                            } catch (Exception e) {}
                        }
                        ((org.opencrx.kernel.base.jmi1.ReferenceProperty)property).setReferenceValue(basicObject);
                    }
                } else if (property_dtype.compareTo(PROPERTY_DTYPE_URI) == 0) {
                    if (property == null) {
                        // create new UriProperty
                        property = basePkg.getUriProperty().createUriProperty();
                        property.refInitialize(false, false);
                        property.setName(property_name);
                        if (productConfigurationType != null) {
                            productConfigurationType.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        } else {
                            propertySet.addProperty(
                                false,
                                getUidAsString(),
                                property
                            );
                        }
                    }
                    if (property != null) {
                        property.setDescription(property_description);
                        ((org.opencrx.kernel.base.jmi1.UriProperty)property).setUriValue(property_value != null ? property_value.getStringCellValue().trim() : null);
                    }
                }
                pm.currentTransaction().commit();
            } catch (Exception e) {
                new ServiceException(e).log();
                try {
                    pm.currentTransaction().rollback();
                } catch(Exception e1) {}
            }
        }
        return property;
    }
%>

<%
    final String EOL_HTML = "<br>";

    request.setCharacterEncoding("UTF-8");
    ApplicationContext app = (ApplicationContext)session.getValue(WebKeys.APPLICATION_KEY);
    Map parameterMap = request.getParameterMap();
    if(FileUpload.isMultipartContent(request)) {
        parameterMap = new HashMap();
        DiskFileUpload upload = new DiskFileUpload();
        upload.setHeaderEncoding("UTF-8");
        try {
            List items = upload.parseRequest(
              request,
              200, // in-memory threshold. Content for fields larger than threshold is written to disk
              50000000, // max request size [overall limit]
              app.getTempDirectory().getPath()
            );
            for(Iterator i = items.iterator(); i.hasNext(); ) {
              FileItem item = (FileItem)i.next();
              if(item.isFormField()) {
                parameterMap.put(
                  item.getFieldName(),
                  new String[]{item.getString("UTF-8")}
                );
              }
              else {
                // reset binary
                if("#NULL".equals(item.getName())) {
                  parameterMap.put(
                    item.getFieldName(),
                    new String[]{item.getName()}
                  );
                }
                // add to parameter map if file received
                else if(item.getSize() > 0) {
                  parameterMap.put(
                    item.getFieldName(),
                    new String[]{item.getName()}
                  );
                  String location = app.getTempFileName(item.getFieldName(), "");

                  // bytes
                  File outFile = new File(location);
                  item.write(outFile);

                  // type
                  PrintWriter pw = new PrintWriter(
                    new FileOutputStream(location + ".INFO")
                  );
                  pw.println(item.getContentType());
                  int sep = item.getName().lastIndexOf("/");
                  if(sep < 0) {
                    sep = item.getName().lastIndexOf("\\");
                  }
                  pw.println(item.getName().substring(sep + 1));
                  pw.close();
                }
              }
            }
        }
        catch(FileUploadException e) {
            SysLog.warning("cannot upload file", e.getMessage());
%>
            <div style="padding:10px 10px 10px 10px;background-color:#FF0000;color:#FFFFFF;">
              <table>
                <tr>
                  <td style="padding:5px;"><b>ERROR</b>:</td>
                  <td>cannot upload file - <%= e.getMessage() %></td>
                </tr>
              </table>
            </div>
<%
        }
    }
    String[] requestIds = (String[])parameterMap.get(Action.PARAMETER_REQUEST_ID);
    String requestId = (requestIds == null) || (requestIds.length == 0) ? request.getParameter(Action.PARAMETER_REQUEST_ID) : requestIds[0];
    String requestIdParam = Action.PARAMETER_REQUEST_ID + "=" + requestId;
    String[] objectXris = (String[])parameterMap.get("xri");
    String objectXri = (objectXris == null) || (objectXris.length == 0) ? null : objectXris[0];
    ViewsCache viewsCache = (ViewsCache)session.getValue(WebKeys.VIEW_CACHE_KEY_SHOW);
    if(objectXri == null || app == null || viewsCache.getView(requestId) == null) {
        response.sendRedirect(
               request.getContextPath() + "/" + WebKeys.SERVLET_NAME
        );
        return;
    }
    javax.jdo.PersistenceManager pm = app.getNewPmData();
    Texts_1_0 texts = app.getTexts();
    Codes codes = app.getCodes();
    Texts_1_0[] textsAllAvailableLocales = app.getTextsFactory().getTexts();
    List<Short> activeLocales = new ArrayList<Short>();
    for(int t = 0; t < textsAllAvailableLocales.length; t++) {
        activeLocales.add(textsAllAvailableLocales[t].getLocaleIndex());
    }
    final String formAction = "ImportPropertiesFromXLS.jsp";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<head>
  <title>Import Properties from Excel Sheet (XLS)</title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="UNUSEDlabel" content="Import Properties from Excel Sheet (XLS)">
  <meta name="UNUSEDtoolTip" content="Import Properties from Excel Sheet (XLS)">
  <meta name="targetType" content="_self">
  <meta name="forClass" content="org:opencrx:kernel:generic:CrxObject">
  <meta name="forClass" content="org:opencrx:kernel:base:PropertySet">
  <meta name="forClass" content="org:opencrx:kernel:product1:Segment">
  <meta name="forClass" content="org:opencrx:kernel:product1:ProductConfigurationTypeSet">
  <meta name="order" content="org:opencrx:kernel:generic:CrxObject:importPropertiesFromXLS">
  <meta name="order" content="org:opencrx:kernel:base:PropertySet:importPropertiesFromXLS">
  <meta name="order" content="org:opencrx:kernel:product1:Segment:importPropertiesFromXLS">
  <meta name="order" content="org:opencrx:kernel:product1:ProductConfigurationTypeSet:importPropertiesFromXLS">
  <link href="../../_style/colors.css" rel="stylesheet" type="text/css">
  <link href="../../_style/n2default.css" rel="stylesheet" type="text/css" />
  <script language="javascript" type="text/javascript" src="../../javascript/prototype.js"></script>

  <link rel='shortcut icon' href='../../images/favicon.ico' />

  <style type="text/css">
      .gridTableHeaderFull TD {
          padding: 1px 5px 1px 5px; /* top right bottom left */
          white-space: nowrap;
      }
      .err {background-color:red;color:white;}
      .ImportTable {border-collapse:collapse;border:1px solid grey;}
      .ImportTable .attributes TD {font-weight:bold;background-color:orange;}
      .ImportTable .sheetInfo TD {background-color:yellow;padding:5px;}
      .ImportTable .importHeader TD {font-weight:bold;background-color:#ddd;}
      .ImportTable TD {white-space:nowrap;border:1px solid grey;padding:1px;}
      .ImportTable TD.empty {background-color:grey;}
      .ImportTable TD.searchAttr {background-color:#CFE9FE;}
      .ImportTable TD.match {background-color:#D2FFD2;}
      .ImportTable TD.create {background-color:#00FF00;}
      .ImportTable TD.ok {background-color:#00FF00;}
      .ImportTable TD.nok {background-color:#FF0000;}
  </style>
</head>

<body>
<div id="container">
    <div id="wrap">
        <div id="fixheader" style="height:90px;">
      <div id="logoTable">
        <table id="headerlayout">
          <tr id="headRow">
            <td id="head" colspan="2">
              <table id="info">
                <tr>
                  <td id="headerCellLeft"><img id="logoLeft" src="../../images/logoLeft.gif" alt="openCRX" title="" /></td>
                  <td id="headerCellSpacerLeft"></td>
                  <td id="headerCellMiddle">&nbsp;</td>
                  <td id="headerCellRight"><img id="logoRight" src="../../images/logoRight.gif" alt="" title="" /></td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </div>
    </div>

    <div id="content-wrap">
        <div id="content" style="padding:10px 0.5em 0px 0.5em;">

<%
    NumberFormat formatter = new DecimalFormat("0000");
    final String UPLOAD_FILE_FIELD_NAME = "uploadFile";
    try {
      boolean actionOk = parameterMap.get("OK.Button") != null;
      boolean actionCancel = parameterMap.get("Cancel.Button") != null;
      boolean continueToExit = false;

      String[] descriptions = (String[])parameterMap.get("description");
      String description = (descriptions == null) || (descriptions.length == 0) ? "" : descriptions[0];

      //System.out.println("XRI=" + objectXri);
      String location = app.getTempFileName(UPLOAD_FILE_FIELD_NAME, "");

      // Get data package. This is the JMI root package to handle
      // openCRX object requests

      RefObject_1_0 obj = (RefObject_1_0)pm.getObjectById(new Path(objectXri));

      // the calling object determines which columns are optional/required in the spreadsheet
      boolean calledFromProductSegment = false;
      boolean calledFromProductConfigurationTypeSet = false;
      boolean calledFromProductConfigurationType = false;
      boolean calledFromPropertySet = false;
      boolean calledFromCrxObject = false;
      org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet productConfigurationTypeSet = null;
      org.opencrx.kernel.product1.jmi1.ProductConfigurationType productConfigurationType = null;
      org.opencrx.kernel.generic.jmi1.PropertySet propertySet = null;
      org.opencrx.kernel.generic.jmi1.CrxObject crxObject = null;
      String callerName = null;
      String callerParentName = null;
      if (obj instanceof org.opencrx.kernel.product1.jmi1.Segment) {
          calledFromProductSegment = true;
          // case 1:
          // required: Property_name
          //           ProductConfigurationTypeSet_name
          //           ProductConfigurationType_name
      } else if (obj instanceof org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet) {
          calledFromProductConfigurationTypeSet = true;
          productConfigurationTypeSet = (org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet)obj;
          callerName = ((org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet)obj).getName();
          // case 2:
          // required: Property_name
          //           ProductConfigurationType_name
          // optional: ProductConfigurationTypeSet_name (if provided, then only Properties of matching ProductConfigurationTypeSets are considered)
      } else if (obj instanceof org.opencrx.kernel.product1.jmi1.ProductConfigurationType) {
          calledFromProductConfigurationType = true;
          productConfigurationType = (org.opencrx.kernel.product1.jmi1.ProductConfigurationType)obj;
          callerName = ((org.opencrx.kernel.product1.jmi1.ProductConfigurationType)obj).getName();
          // get parent object
          RefObject_1_0 parentObj = (RefObject_1_0)pm.getObjectById(new Path(obj.refMofId()).getParent().getParent());
          if (parentObj instanceof org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet) {
              callerParentName = ((org.opencrx.kernel.product1.jmi1.ProductConfigurationTypeSet)parentObj).getName();
          }

          // case 3:
          // required: Property_name
          // optional: ProductConfigurationTypeSet_name (if provided, then only Properties of matching ProductConfigurationTypeSets are considered)
          //           ProductConfigurationType_name (if provided, then only Properties of matching ProductConfigurationTypes are considered)
      } else if (obj instanceof org.opencrx.kernel.generic.jmi1.PropertySet) {
          calledFromPropertySet = true;
          propertySet = (org.opencrx.kernel.generic.jmi1.PropertySet)obj;
          callerName = propertySet.getName();
          // case 4:
          // required: Property_name
          // optional: PropertySet_name (if provided, then only Properties of matching PropertySets are considered)
      } else if (obj instanceof org.opencrx.kernel.generic.jmi1.CrxObject) {
          calledFromCrxObject = true;
          crxObject = (org.opencrx.kernel.generic.jmi1.CrxObject)obj;
          // case 5:
          // required: PropertySet_name
          //           Property_name
      }

      Path objectPath = new Path(objectXri);
      String providerName = objectPath.get(2);
      String segmentName = objectPath.get(4);

      //Set userRoles = app.getUserRoles();
      String currentUserRole = app.getCurrentUserRole();
      String adminRole = "admin-" + segmentName + "@" + segmentName;
      boolean permissionOk = currentUserRole.compareTo(adminRole) == 0;
      permissionOk = true;

      if(actionCancel || (objectXri == null) || (!permissionOk)) {
          Action nextAction = new ObjectReference(
            (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
            app
          ).getSelectObjectAction();
          continueToExit = true;
          if (actionCancel) {
              response.sendRedirect(
                  request.getContextPath() + "/" + nextAction.getEncodedHRef()
              );
          } else {
              String errorMessage = "Cannot upload Excel File!)";
              if (!permissionOk) {errorMessage = "no permission to run this wizard";}
%>
                  <br />
                  <br />
                  <span style="color:red;"><b><u>ERROR:</u> <%= errorMessage %></b></span>
                  <br />
                  <br />
                  <INPUT type="Submit" name="Cancel.Button" tabindex="1" value="Weiter" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
                  <br />
                  <br />
                  <hr>
<%
          }
      }
      else if(actionOk) {
          if(
              new File(location + ".INFO").exists() &&
              new File(location).exists() &&
              (new File(location).length() > 0)
          ) {
              // mimeType and name
              BufferedReader r = new BufferedReader(
                  new FileReader(location + ".INFO")
              );
              String contentMimeType = r.readLine();
              String contentName = r.readLine();
              r.close();
              new File(location + ".INFO").delete();

              if(
                  (contentName != null) &&
                  (contentName.length() > 0) &&
                  (contentMimeType != null) &&
                  (contentMimeType.length() > 0)
              ) {
                  try {
                      java.util.Date today = new java.util.Date();

                      // Get generic package
                      org.opencrx.kernel.generic.jmi1.GenericPackage genericPkg = org.opencrx.kernel.utils.Utils.getGenericPackage(pm);

                      // Get base package
                      org.opencrx.kernel.base.jmi1.BasePackage basePkg = org.opencrx.kernel.utils.Utils.getBasePackage(pm);

                      // Get product package
                      org.opencrx.kernel.product1.jmi1.Product1Package productPkg = org.opencrx.kernel.utils.Utils.getProductPackage(pm);

                      // Get product segment
                      org.opencrx.kernel.product1.jmi1.Segment productSegment =
                        (org.opencrx.kernel.product1.jmi1.Segment)pm.getObjectById(
                          new Path("xri:@openmdx:org.opencrx.kernel.product1/provider/" + providerName + "/segment/" + segmentName)
                         );

                      int idxProperty_dtype = -1;
                      int idxProperty_name = -1;
                      int idxProperty_description = -1;
                      int idxProperty_value = -1;
                      int idxPropertySet_name = -1;
                      int idxPropertySet_description = -1;
                      int idxProductConfigurationTypeSet_name = -1;
                      int idxProductConfigurationTypeSet_description = -1;
                      int idxProductConfigurationType_name = -1;
                      int idxProductConfigurationType_description = -1;

                      // verify whether File exists
                      POIFSFileSystem fs = null;
                      try {
                        fs = new POIFSFileSystem(new FileInputStream(location));
                      } catch (Exception e) {}

                      if(permissionOk && actionOk && (fs != null)) {
                          continueToExit = true;

                          try {
                              HSSFWorkbook workbook = new HSSFWorkbook(fs);
                              //for (int i = 0; i < workbook.getNumberOfSheets(); i++) {
                              // read first sheet only!!!
                              for (int i = 0; i < 1; i++) {
                                  HSSFSheet sheet = workbook.getSheetAt(i);
                                  int linesRead = 0;
                                  int propertiesUpdated = 0;
%>
                                  <table class="ImportTable">
<%
                                  Iterator rows = sheet.rowIterator();
                                  int nRow = 0;
                                  int maxCell = 0;
                                  HSSFRow row = null;

                                  Map attributeMap = new TreeMap();
                                  if (rows.hasNext()) {
                                       nRow += 1;
                                      // read first row with attribute names
%>
                                      <tr class="attributes">
                                          <td>Row <%= formatter.format(nRow) %><br>&nbsp;</td>
<%
                                          row = (HSSFRow) rows.next();
                                          try {
                                              Iterator cells = row.cellIterator();
                                              int nCell = 0;
                                              while (cells.hasNext()) {
                                                  HSSFCell cell = (HSSFCell)cells.next();
                                                  nCell = cell.getCellNum();
                                                  if (nCell > maxCell) {
                                                      maxCell = nCell;
                                                  }
                                                  try {
                                                      if (
                                                          (cell.getCellType() == HSSFCell.CELL_TYPE_STRING) &&
                                                          (cell.getStringCellValue() != null)
                                                      ) {
                                                          boolean isSearchAttribute = false;
                                                          String cellValue = (cell.getStringCellValue().trim());
                                                          attributeMap.put(formatter.format(nCell), cellValue);
                                                          // get idx of select attributes
                                                          if (ATTR_PROPERTY_DTYPE.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProperty_dtype = nCell;
                                                          } else if (ATTR_PROPERTY_NAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProperty_name = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_PROPERTY_DESCRIPTION.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProperty_description = nCell;
                                                          } else if (ATTR_PROPERTY_VALUE.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProperty_value = nCell;
                                                          } else if (ATTR_PROPERTYSET_NAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxPropertySet_name = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_PROPERTYSET_DESCRIPTION.compareToIgnoreCase(cellValue) == 0) {
                                                              idxPropertySet_description = nCell;
                                                          } else if (ATTR_PRODUCTCONFIGURATIONTYPESET_NAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProductConfigurationTypeSet_name = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_PRODUCTCONFIGURATIONTYPESET_DESCRIPTION.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProductConfigurationTypeSet_description = nCell;
                                                          } else if (ATTR_PRODUCTCONFIGURATIONTYPE_NAME.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProductConfigurationType_name = nCell;
                                                              isSearchAttribute = true;
                                                          } else if (ATTR_PRODUCTCONFIGURATIONTYPE_DESCRIPTION.compareToIgnoreCase(cellValue) == 0) {
                                                              idxProductConfigurationType_description = nCell;
                                                          }
%>
                                                          <td <%= isSearchAttribute ? "class='searchAttr' title='attribute used for matching'" : "" %>>Col-<%= formatter.format(nCell) + EOL_HTML + cellValue %></td>
<%
                                                      } else {
%>
                                                          <td class="err">c<%= formatter.format(nCell) %>[not a string cell]<br><%= cell.getCellFormula() %></td>
<%
                                                      }
                                                  } catch (Exception ec) {
                                                        new ServiceException(ec).log();
%>
                                                        <td class="err">c<%= formatter.format(nCell) %> [UNKNOWN ERROR]<br><%= cell.getCellFormula() %></td>
<%
                                                  }
                                              }
                                          } catch (Exception e) {
                                              new ServiceException(e).log();
%>
                                              <td class="err">ERROR in Attribute Row!</td>
<%
                                          }
%>
                                      </tr>
<%
                                  }
                                  while (rows.hasNext()) {
                                      nRow += 1;
                                      linesRead += 1;

                                      row = (HSSFRow) rows.next();
                                      String property_dtype = null;
                                      String property_name = null;
                                      String property_description = null;
                                      HSSFCell property_value = null;
                                      String propertySet_name = null;
                                      String propertySet_description = null;
                                      String productConfigurationTypeSet_name = null;
                                      String productConfigurationTypeSet_description = null;
                                      String productConfigurationType_name = null;
                                      String productConfigurationType_description = null;

                                      String cellId = null;
                                      //Map valueMap = new TreeMap();
                                      Map valueMap = new TreeMap<String,Object>(String.CASE_INSENSITIVE_ORDER);
                                      String appendErrorRow = null;
%>
                                      <tr>
                                          <td id='r<%= nRow %>'><b>Row <%= formatter.format(nRow) %></b></td>
<%
                                          String jsBuffer = "";
                                          boolean isOk = false;
                                          boolean isNok = false;
                                          try {
                                              Iterator cells = row.cellIterator();
                                              int nCell = 0;
                                              int currentCell = 0;
                                              appendErrorRow = null;
                                              while (cells.hasNext()) {
                                                  //HSSFCell cell = (HSSFCell)row.getCell((short)0);
                                                  HSSFCell cell = (HSSFCell)cells.next();
                                                  nCell = cell.getCellNum();
                                                  if (nCell > currentCell) {
%>
                                                      <td colspan="<%= nCell-currentCell %>" class="empty">&nbsp;</td>
<%
                                                  }
                                                  currentCell = nCell+1;
                                                  try {
                                                      cellId =  "id='r" + nRow + (attributeMap.get(formatter.format(nCell))).toString().toUpperCase() + "'";
                                                      if (cell.getCellType() == HSSFCell.CELL_TYPE_STRING) {
                                                          String cellValue = cell.getStringCellValue().trim();
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cell);
                                                          if (nCell == idxProperty_dtype) {
                                                              property_dtype = cellValue;
                                                          } else if (nCell == idxProperty_name) {
                                                              property_name = cellValue;
                                                          } else if (nCell == idxProperty_description) {
                                                              property_description = cellValue;
                                                          } else if (nCell == idxProperty_value) {
                                                              property_value = cell;
                                                          } else if (nCell == idxPropertySet_name) {
                                                              propertySet_name = cellValue;
                                                          } else if (nCell == idxPropertySet_description) {
                                                              propertySet_description = cellValue;
                                                          } else if (nCell == idxProductConfigurationTypeSet_name) {
                                                              productConfigurationTypeSet_name = cellValue;
                                                          } else if (nCell == idxProductConfigurationTypeSet_description) {
                                                              productConfigurationTypeSet_description = cellValue;
                                                          } else if (nCell == idxProductConfigurationType_name) {
                                                              productConfigurationType_name = cellValue;
                                                          } else if (nCell == idxProductConfigurationType_description) {
                                                              productConfigurationType_description = cellValue;
                                                          }
%>
                                                          <td <%= cellId %>><%= cellValue != null ? (cellValue.replace("\r\n", EOL_HTML)).replace("\n", EOL_HTML) : "" %></td>
<%
                                                      } else if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC) {
                                                          if (nCell == idxProperty_value) {
                                                              property_value = cell;
                                                          }
                                                          BigDecimal cellValue = new BigDecimal(cell.getNumericCellValue());
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cell);
%>
                                                          <td <%= cellId %>><%= cellValue %></td>
<%
                                                      } else if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN) {
                                                          if (nCell == idxProperty_value) {
                                                              property_value = cell;
                                                          }
                                                          boolean cellValue = cell.getBooleanCellValue();
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cell);
%>
                                                          <td <%= cellId %>><%= cellValue ? "TRUE" : "FALSE" %></td>
<%
                                                      } else if (cell.getCellType() == HSSFCell.CELL_TYPE_BLANK) {
                                                          /* leave property_value at null
                                                          if (nCell == idxProperty_value) {
                                                              property_value = cell;
                                                          }
                                                          */
                                                          valueMap.put((attributeMap.get(formatter.format(nCell))).toString(), cell);
%>
                                                          <td <%= cellId %> class="empty">&nbsp;</td>
<%
                                                      } else {
%>
                                                          <td class="err">r<%= formatter.format(nRow) %>-c<%= formatter.format(nCell) %>[cell-type (<%= cell.getCellType() %>) not supported]<br><%= cell.getCellFormula() %></td>
<%
                                                      }
                                                  } catch (Exception ec) {
                                                      new ServiceException(ec).log();
%>
                                                      <td class="err">r<%= formatter.format(nRow) %>-c<%= formatter.format(nCell) %> [UNKNOWN ERROR]<br><%= cell.getCellFormula() %></td>
<%
                                                  }
                                              }
                                              if (nCell < maxCell) {
%>
                                                  <td colspan="<%= maxCell-nCell %>" class="empty"></td>
<%
                                              }
                                          } catch (Exception e) {
                                              new ServiceException(e).log();
%>
                                              <td class="err" colspan="<%= maxCell+2 %>">ERROR in Attribute Row!</td>
<%
                                          }

                                          // process row
                                          org.opencrx.kernel.base.jmi1.Property property = null;
                                          if (isSupportedDtypeValue(property_dtype, property_value)) {

/* case 1 */                                  if (
                                                  calledFromProductSegment &&
                                                  property_name != null && property_name.length() > 0 &&
                                                  productConfigurationTypeSet_name != null && productConfigurationTypeSet_name.length() > 0 &&
                                                  productConfigurationType_name != null && productConfigurationType_name.length() > 0
                                              ) {
                                                  jsBuffer += "$('r" + nRow + "').title += 'Property Of ProductConfigurationTypeSet (called from Product Segment)';";
                                                  if (
                                                      (propertySet_name == null || propertySet_name.length() == 0)
                                                  ) {
                                                      property = createOrUpdatePropertyOfPropertySet(
                                                          productConfigurationTypeSet,
                                                          productConfigurationTypeSet_name,
                                                          productConfigurationTypeSet_description,
                                                          productConfigurationType,
                                                          productConfigurationType_name,
                                                          productConfigurationType_description,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          property_dtype,
                                                          property_name,
                                                          property_description,
                                                          property_value,
                                                          productSegment,
                                                          productPkg,
                                                          basePkg,
                                                          genericPkg,
                                                          pm,
                                                          app
                                                      );
                                                      if (property != null) {
                                                          updateProductConfigurationType(
                                                              (org.opencrx.kernel.product1.jmi1.ProductConfigurationType)pm.getObjectById(new Path(property.refMofId()).getParent().getParent()),
                                                              valueMap,
                                                              pm
                                                          );
                                                      }
                                                  } else {
                                                      jsBuffer += "$('r" + nRow + "').title += ' - verify data row';";
                                                  }

/* case 2 */                                  } else if (
                                                  calledFromProductConfigurationTypeSet &&
                                                  property_name != null && property_name.length() > 0 &&
                                                  productConfigurationType_name != null && productConfigurationType_name.length() > 0
                                              ) {
                                                  jsBuffer += "$('r" + nRow + "').title += 'Property Of ProductConfigurationTypeSet (called from ProductConfigurationTypeSet)';";
                                                  if (
                                                      (
                                                        (productConfigurationTypeSet_name == null || productConfigurationTypeSet_name.length() == 0) ||
                                                        (callerName != null && productConfigurationTypeSet_name != null && callerName.compareTo(productConfigurationTypeSet_name) == 0)
                                                      ) &&
                                                      (propertySet_name == null || propertySet_name.length() == 0)
                                                  ) {
                                                      property = createOrUpdatePropertyOfPropertySet(
                                                          productConfigurationTypeSet,
                                                          productConfigurationTypeSet_name,
                                                          productConfigurationTypeSet_description,
                                                          productConfigurationType,
                                                          productConfigurationType_name,
                                                          productConfigurationType_description,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          property_dtype,
                                                          property_name,
                                                          property_description,
                                                          property_value,
                                                          productSegment,
                                                          productPkg,
                                                          basePkg,
                                                          genericPkg,
                                                          pm,
                                                          app
                                                      );
                                                      if (property != null) {
                                                          updateProductConfigurationType(
                                                              (org.opencrx.kernel.product1.jmi1.ProductConfigurationType)pm.getObjectById(new Path(property.refMofId()).getParent().getParent()),
                                                              valueMap,
                                                              pm
                                                          );
                                                      }
                                                  } else {
                                                      jsBuffer += "$('r" + nRow + "').title += ' - verify data row';";
                                                  }

/* case 3 */                                  } else if (
                                                  calledFromProductConfigurationType &&
                                                  property_name != null && property_name.length() > 0
                                              ) {
                                                  jsBuffer += "$('r" + nRow + "').title += 'Property Of ProductConfigurationTypeSet (called from ProductConfigurationType)';";
                                                  if (
                                                      (
                                                        (productConfigurationTypeSet_name == null || productConfigurationTypeSet_name.length() == 0) ||
                                                        (callerParentName != null && productConfigurationTypeSet_name != null && callerParentName.compareTo(productConfigurationTypeSet_name) == 0)
                                                      ) &&
                                                      (
                                                        (productConfigurationType_name == null || productConfigurationType_name.length() == 0) ||
                                                        (callerName != null && productConfigurationType_name != null && callerName.compareTo(productConfigurationType_name) == 0)
                                                      ) &&
                                                      (propertySet_name == null || propertySet_name.length() == 0)
                                                  ) {
                                                      property = createOrUpdatePropertyOfPropertySet(
                                                          productConfigurationTypeSet,
                                                          productConfigurationTypeSet_name,
                                                          productConfigurationTypeSet_description,
                                                          productConfigurationType,
                                                          productConfigurationType_name,
                                                          productConfigurationType_description,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          property_dtype,
                                                          property_name,
                                                          property_description,
                                                          property_value,
                                                          productSegment,
                                                          productPkg,
                                                          basePkg,
                                                          genericPkg,
                                                          pm,
                                                          app
                                                      );
                                                      if (property != null) {
                                                          updateProductConfigurationType(
                                                              (org.opencrx.kernel.product1.jmi1.ProductConfigurationType)pm.getObjectById(new Path(property.refMofId()).getParent().getParent()),
                                                              valueMap,
                                                              pm
                                                          );
                                                      }
                                                  } else {
                                                      jsBuffer += "$('r" + nRow + "').title += ' - verify data row';";
                                                  }

/* case 4 */                                  } else if (
                                                  calledFromPropertySet &&
                                                  property_name != null && property_name.length() > 0
                                              ) {
                                                  jsBuffer += "$('r" + nRow + "').title += 'Property Of PropertySet (called from PropertySet)';";
                                                  if (
                                                      (
                                                        (propertySet_name == null || propertySet_name.length() == 0) ||
                                                        (callerName != null && propertySet_name != null && callerName.compareTo(propertySet_name) == 0)
                                                      ) &&
                                                      (productConfigurationTypeSet_name == null || productConfigurationTypeSet_name.length() == 0) &&
                                                      (productConfigurationType_name == null || productConfigurationType_name.length() == 0)
                                                  ) {
                                                      property = createOrUpdatePropertyOfPropertySet(
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          propertySet,
                                                          propertySet_name,
                                                          propertySet_description,
                                                          property_dtype,
                                                          property_name,
                                                          property_description,
                                                          property_value,
                                                          productSegment,
                                                          productPkg,
                                                          basePkg,
                                                          genericPkg,
                                                          pm,
                                                          app
                                                      );
                                                  } else {
                                                      jsBuffer += "$('r" + nRow + "').title += ' - verify data row';";
                                                  }

/* case 5 */                                  } else if (
                                                  calledFromCrxObject &&
                                                  property_name != null && property_name.length() > 0 &&
                                                  propertySet_name != null && propertySet_name.length() > 0
                                              ) {
                                                  jsBuffer += "$('r" + nRow + "').title += 'Property Of PropertySet (called from CrxObject)';";
                                                  if (
                                                      (productConfigurationTypeSet_name == null || productConfigurationTypeSet_name.length() == 0) &&
                                                      (productConfigurationType_name == null || productConfigurationType_name.length() == 0)
                                                  ) {
                                                      //createOrUpdatePropertyOfPropertySet
                                                      property = createOrUpdatePropertyOfPropertySet(
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          crxObject,
                                                          null,
                                                          propertySet_name,
                                                          propertySet_description,
                                                          property_dtype,
                                                          property_name,
                                                          property_description,
                                                          property_value,
                                                          productSegment,
                                                          productPkg,
                                                          basePkg,
                                                          genericPkg,
                                                          pm,
                                                          app
                                                      );
                                                  } else {
                                                      jsBuffer += "$('r" + nRow + "').title += ' - verify data row';";
                                                  }
                                              } else {
                                                  // incomplete and/or inconsistent row --> disregard this row
                                                  jsBuffer += "$('r" + nRow + "').title += 'incomplete and/or inconsistent row';";

                                              }
                                          } else {
                                              appendErrorRow = "<tr><td class='err' colspan='" + (maxCell+2) + "'>CELL VALUE TYPE NOT SUPPORTED</td></tr>";
                                          }
%>
                                      </tr>
<%
                                      String propertyHref = "";
                                      if (property != null) {
                                          propertiesUpdated++;
                                          Action action = new Action(
                                              SelectObjectAction.EVENT_ID,
                                              new Action.Parameter[]{
                                                  new Action.Parameter(Action.PARAMETER_OBJECTXRI, property.refMofId())
                                              },
                                              "",
                                              true // enabled
                                          );
                                          propertyHref = "../../" + action.getEncodedHRef();
                                          cellId =  "r" + nRow + ATTR_PROPERTY_NAME.toUpperCase();
                                          jsBuffer += "try{$('r" + nRow + "').className += ' ok';$('" + cellId + "').className=' ok';$('" + cellId + "').innerHTML = '<a href=\"" + propertyHref + "\" target=\"_blank\"><b>' + " + "$('" + cellId + "').innerHTML +" + "'</b></a>'}catch(e){};";
                                          cellId =  "r" + nRow + ATTR_PROPERTY_VALUE.toUpperCase();
                                          if (property_value != null) {
                                            jsBuffer += "try{$('" + cellId + "').className=' ok';}catch(e){};";
                                          }

                                      } else {
                                          appendErrorRow = "<tr><td class='err' colspan='" + (maxCell+2) + "'>VERIFY Property DTYPE/NAME/VALUE</td></tr>";
                                          jsBuffer += "$('r" + nRow + "').className += ' nok';";
                                      }
                                      if (appendErrorRow != null) {
%>
                                          <%= appendErrorRow %>
<%
                                      }
                                      valueMap = null;
%>
                                      <tr style="display:none;">
                                          <td colspan="<%= maxCell+2 %>">
                                              <%= jsBuffer.length() > 0 ? "<script language='javascript' type='text/javascript'>" + jsBuffer + "</script>" : "" %>
                                          </td>
                                      </tr>
<%
                                  } /* while */
%>
                                  <tr class="sheetInfo">
                                      <td colspan="<%= maxCell+2 %>">
                                          Sheet: <b><%= workbook.getSheetName(i) %></b> |
                                          data lines <b>read: <%= linesRead %></b><br>
                                      </td>
                                  </tr>
                                  <tr class="importHeader">
                                      <td>DTYPE</td>
                                      <td colspan="<%= maxCell+1 %>">created / updated</td>
                                  </tr>
                                  <tr>
                                      <td>Properties</td>
                                      <td colspan="<%= maxCell+1 %>"><%= propertiesUpdated %></td>
                                  </tr>
<%
                                  if (
                                    linesRead != propertiesUpdated
                                  ) {
%>
                                    <tr>
                                        <td class="err" colspan="<%= maxCell+2 %>">WARNING: some data lines were not processed due to data errors (e.g. multiple matches, missing name, etc.)</td>
                                    </tr>
<%
                                  }
%>
                                  </table>
<%
                              } /* for */
%>
                              <hr>
<%
                          } catch (Exception e) {
                              ServiceException e0 = new ServiceException(e);
                              e0.log();
                              out.println("<div style='color:red;padding:5px;margin:10px;'><b><u>Warning:</u> Error reading/processing Excel file!<br><br>The following exception(s) occured:</b><br><br><pre>");
                              PrintWriter pw = new PrintWriter(out);
                              e0.printStackTrace(pw);
                              out.println("</pre></div>");
                          }
                      }
                      new File(location).delete();

                      // Go back to previous view
                      Action nextAction =
                        new Action(
                          SelectObjectAction.EVENT_ID,
                          new Action.Parameter[]{
                              new Action.Parameter(Action.PARAMETER_OBJECTXRI, objectXri)
                          },
                          "", true
                        );
%>
                      <br />
                      <br />
                      <INPUT type="Submit" name="Cancel.Button" tabindex="1" value="Continue" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
                      <br />
                      <br />
<%
                  }
                  catch(Exception e) {
                      new ServiceException(e).log();
                  }
              }
          }
          else {

          }
      }
      else {
          File uploadFile = new File(location);
          System.out.println("Import: file " + location + " either does not exist or has size 0: exists=" + uploadFile.exists() + "; length=" + uploadFile.length());
      }
      if (!continueToExit) {
%>
<form name="UploadMedia" enctype="multipart/form-data" accept-charset="UTF-8" method="POST" action="<%= formAction %>">
<input type="hidden" class="valueL" name="xri" value="<%= objectXri %>" />
<input type="hidden" name="<%= Action.PARAMETER_REQUEST_ID %>" value="<%= requestId %>" />
<table cellspacing="8" class="tableLayout">
  <tr>
    <td class="cellObject">
      <noscript>
        <div class="panelJSWarning" style="display: block;">
          <a href="../../helpJsCookie.html" target="_blank"><img class="popUpButton" src="../../images/help.gif" width="16" height="16" border="0" onclick="javascript:void(window.open('helpJsCookie.html', 'Help', 'fullscreen=no,toolbar=no,status=no,menubar=no,scrollbars=yes,resizable=yes,directories=no,location=no,width=400'));" alt="" /></a> <%= texts.getPageRequiresScriptText() %>
        </div>
      </noscript>
      <div id="etitle" style="height:20px;">
         Import Properties from Excel Sheet (XLS) - 1 property per row<br>
      </div>

      <div class="panel" id="panelObj0" style="display: block">
        <div class="fieldGroupName">
          <span style="font-size:9px;">(Hint: row 1 contains field names, data starts at row 2)</span>
        </div>
        <br>
        <table class="fieldGroup">
          <tr id="waitMsg" style="display:none;">
            <td colspan="3">
              <table class="objectTitle">
                <tr>
                  <td>
                    <div style="padding-left:5px; padding-bottom: 3px;">
                      Processing request - please wait...<br>
                      <img border="0" src='../../images/progress_bar.gif' alt='please wait...' />
                    </div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr id="submitFilename">
            <td class="label"><span class="nw">File:</span></td>
            <td >
                <input type="file" class="valueL" size="100" name="<%= UPLOAD_FILE_FIELD_NAME %>" tabindex="500" />
            </td>
            <td class="addon" >&nbsp;<br>&nbsp;</td>
          </tr>
          <tr id="submitButtons">
            <td class="label" colspan="3">
                <INPUT type="Submit" name="OK.Button" tabindex="1000" value="Importieren" onclick="javascript:$('waitMsg').style.display='block';$('submitButtons').style.visibility='hidden';$('submitFilename').style.visibility='hidden';" />
                  <INPUT type="Submit" name="Cancel.Button" tabindex="1010" value="Abbrechen" />
            </td>
            <td></td>
            <td class="addon" >&nbsp;<br>&nbsp;</td>
          </tr>
        </table>
      </div>
    </td>
  </tr>
</table>
</form>
<%
      }
    }
    catch (Exception ex) {
        Action nextAction = new ObjectReference(
          (RefObject_1_0)pm.getObjectById(new Path(objectXri)),
          app
        ).getSelectObjectAction();
%>
        <br />
        <br />
        <span style="color:red;"><b><u>Warning:</u> cannot upload file (no permission?)</b></span>
        <br />
        <br />
        <INPUT type="Submit" name="Continue.Button" tabindex="1" value="Continue" onClick="javascript:location='<%= request.getContextPath() + "/" + nextAction.getEncodedHRef() %>';" />
        <br />
        <br />
        <hr>
<%
        ServiceException e0 = new ServiceException(ex);
        e0.log();
        out.println("<p><b>!! Failed !!<br><br>The following exception(s) occured:</b><br><br><pre>");
        PrintWriter pw = new PrintWriter(out);
        e0.printStackTrace(pw);
        out.println("</pre></p>");
    } finally {
    	if(pm != null) {
    		pm.close();
    	}
    }
%>
      </div> <!-- content -->
    </div> <!-- content-wrap -->
  </div> <!-- wrap -->
</div> <!-- container -->
</body>
</html>
