// PluginConfigList.java --
//
// PluginConfigList.java is part of ElectricCommander.
//
// Copyright (c) 2005-2015 Electric Cloud, Inc.
// All rights reserved.
//

package ecplugins.$[/myJob/javaName].client;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.xml.client.Document;
import com.google.gwt.xml.client.Node;
import com.google.gwt.xml.client.XMLParser;

import static com.electriccloud.commander.gwt.client.util.XmlUtil.getNodeByName;
import static com.electriccloud.commander.gwt.client.util.XmlUtil.getNodeValueByName;
import static com.electriccloud.commander.gwt.client.util.XmlUtil.getNodesByName;

public class PluginConfigList
{

    //~ Instance fields --------------------------------------------------------

    private final Map<String, PluginConfigInfo> m_configInfo =
        new TreeMap<String,  PluginConfigInfo>();

    //~ Methods ----------------------------------------------------------------

    public void addConfig(
            String configName,
            String configUrl)
    {
        m_configInfo.put(configName, new PluginConfigInfo(configUrl));
    }

    public String parseResponse(String cgiResponse)
    {
        Document document     = XMLParser.parse(cgiResponse);
        Node     responseNode = getNodeByName(document, "response");
        String   error        = getNodeValueByName(responseNode, "error");

        if (error != null && !error.isEmpty()) {
            return error;
        }

        Node       configListNode = getNodeByName(responseNode, "cfgs");
        List<Node> configNodes    = getNodesByName(configListNode, "cfg");

        for (Node configNode : configNodes) {
            String configName   = getNodeValueByName(configNode, "name");
            String configUrl = getNodeValueByName(configNode, "url");

            addConfig(configName, configUrl);
        }

        return null;
    }

    public void populateConfigListBox(ListBox lb)
    {

        for (String configName : m_configInfo.keySet()) {
            lb.addItem(configName);
        }
    }

    public Set<String> getConfigNames()
    {
        return m_configInfo.keySet();
    }

    public String getConfigUrl(String configName)
    {
        return m_configInfo.get(configName).m_url;
    }

    public String getEditorDefinition(String configName)
    {
        return "$[/myJob/pluginName]";
    }

    public boolean isEmpty()
    {
        return m_configInfo.isEmpty();
    }

    public void setEditorDefinition(
            String configUrl,
            String editorDefiniton)
    {
    }

    //~ Inner Classes ----------------------------------------------------------

    private class PluginConfigInfo
    {

        //~ Instance fields ----------------------------------------------------

        private String m_url;

        //~ Constructors -------------------------------------------------------

        public  PluginConfigInfo(String url)
        {
            m_url = url;
        }
    }
}
