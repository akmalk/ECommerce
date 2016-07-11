/*
 * Copyright 2015 AppDynamics, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *//*


*/
/**
 * OrderService.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 *//*


package com.appdynamics.inventory;

public interface OrderService extends javax.xml.rpc.Service {
    public java.lang.String getOrderServiceSOAP11port_httpAddress();

    public com.appdynamics.inventory.OrderServicePortType getOrderServiceSOAP11port_http() throws javax.xml.rpc.ServiceException;

    public com.appdynamics.inventory.OrderServicePortType getOrderServiceSOAP11port_http(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
    public java.lang.String getOrderServiceSOAP12port_httpAddress();

    public com.appdynamics.inventory.OrderServicePortType getOrderServiceSOAP12port_http() throws javax.xml.rpc.ServiceException;

    public com.appdynamics.inventory.OrderServicePortType getOrderServiceSOAP12port_http(java.net.URL portAddress) throws javax.xml.rpc.ServiceException;
}
*/

package com.appdynamics.inventory;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.7-b01-
 * Generated source version: 2.1
 *
 */
@WebService(name = "OrderService", targetNamespace = "http://inventory.appdynamics.com/")
@SOAPBinding(style = SOAPBinding.Style.RPC)
@XmlSeeAlso({
        ObjectFactory.class
})
public interface OrderService {


    /**
     *
     * @param arg1
     * @param arg0
     * @return
     *     returns long
     */
    @WebMethod
    @WebResult(partName = "return")
    public long createPO(
            @WebParam(name = "arg0", partName = "arg0")
            long arg0,
            @WebParam(name = "arg1", partName = "arg1")
            int arg1);

    /**
     *
     * @param arg0
     * @return
     *     returns long
     */
    @WebMethod
    @WebResult(partName = "return")
    public long createOrder(
            @WebParam(name = "arg0", partName = "arg0")
            OrderRequest arg0);

}