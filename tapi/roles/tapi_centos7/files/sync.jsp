<%@ page session="false" %>
<%
try {
	String url = request.getParameter("rd");
	int expireDays = 1000;
	String domain = "admatrix.jp";
	String uid = null;
	String uidKey = "uid";
	boolean optout = false;
	String optoutKey = "oc";
	
	Cookie[] cookies = request.getCookies();
	if(cookies != null) {
		for(int i = 0; i < cookies.length; i++) {
			if(uidKey.equals(cookies[i].getName())) {
				uid = cookies[i].getValue();
			} else if(optoutKey.equals(cookies[i].getName())) {
				if("1".equals(cookies[i].getValue())) optout = true;
			}
		}
	}
	if(uid == null) {
		uid = createUid();
		Cookie cookie = new Cookie(uidKey, uid);
		cookie.setMaxAge(expireDays * 24 * 3600);
		cookie.setPath("/");
		cookie.setDomain(domain);
		response.addHeader("P3P", "CP='CAO PSA CONi OTR OUR DEM ONL'");
		response.addCookie(cookie);
	}
	
	if(url != null) {
		url = url + uid;
		if(optout) url = url + "&optout=1";
		//out.println(url);
		response.sendRedirect(url);
	}
} catch(Exception e) {
}
%>
<%!
private String createUid() throws Exception {
	return java.util.UUID.randomUUID().toString();
}
%>
