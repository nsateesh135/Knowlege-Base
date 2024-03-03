# XML : Extended Markup Language 

In XML we use tage <> or marks hence markup and we can create our own tags which are extebdable 

1. XML is used to move data between 2 applications (maybe from client to
   server applications)
2. Used to share and transport data 
3. Bound to W3C(world-wide-web-consortium) recommendation
4. It is software and hardware independent way of storing, transporting
   and sharing data(like JSON files)
5. It is both human and machine readable

Example : 

```xml
<friendsList>
   <friend>
      <name>Alex</name>
   </friend>
    <friend>
        <name>Mary</name>
    </friend>
    <friend>
      <name>Rachel</name>
   </friend>
   <bestFriend>
      <name>Rachel</name>
   </bestFriend>
</friendsList>
```
Once you write you XML pass your code through a formatter like 
https://jsonformatter.org/xml-formatter

```xml
<friendsList>
	<friend>
		<name>Alex</name>
	</friend>
	<friend>
		<name>Mary</name>
	</friend>
	<friend>
		<name>Rachel</name>
	</friend>
	<bestFriend>
		<name>Rachel</name>
	</bestFriend>
</friendsList>
```
## XML Tree View 
```
object	{1}
   friendsList {2}
    friend [3]
	    0 {1}
           name	: Alex
	    1 {1}
           name	:	Mary
	    2 {1}
           name	:	Rachel
	bestFriend {1}
           name	:	Rachel
```

## XML Validation 

1. We need to make sure XML is either in DTD(Document Type Definition) 
   or XSD(XML schema Definition) syntax/structure/fomat to render data. 
2. If we don't have any current schema setup then we can use an online 
   tool generate a DTD or XSD schema 

## DOM: Document Object Model 
1. DOM represents the content of XML or HTML document in a tree structure
2. Document : file ; Object : tags/elements; Model: layout structure
3. Can easily read, access or update the contents of the document 
4. Is a programming interface(API)
5. ```xmlDoc.getElementByTagName('title'[0].childNodes[0].nodeValue)```
   This above code retrieves the text value of the first <title> element in an XML document
6. DOM is an object oriented representation of the webpage,which can be 
   modified with a scripting language such as JavaScript