<?xml version="1.0"?>

<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns="http://www.w3.org/2000/svg"
		>
  <xsl:output
      method="xml"
      indent="yes"
      standalone="no"
      doctype-public="-//W3C//DTD SVG 1.1//EN"
      doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"
      media-type="image/svg" />


  <xsl:variable name="sy" select="timeline/@startYear" />
  
  <xsl:template match="timeline">
    <svg xmlns="http://www.w3.org/2000/svg" width="{concat(4 + @numYears * 12, 'cm')}" height="{concat(4 + @lanes * 4, 'cm')}" >
      <style>
    .eventText {
        font-family: sans-serif;
        font-size: 3mm;
        text-align: center;
        text-anchor: middle;
    }
    .eventDate {
        font-family: sans-serif;
        font-size: 3mm;
        text-align: center;
        text-anchor: middle;
        font-style: italic;
    }
    .eventGroupDesc {
        font-family: sans-serif;
        font-size: 3mm;
        text-align: center;
        text-anchor: left;
        font-style: italic;
    }
    .eventBar {
        fill: rgb(0,0,0);
    }
    .eventGroup {
        fill: none;
        stroke: black;
        stroke-dasharray: 5,5;
    }
    .year {
        font-family: sans-serif;
        font-size: 7mm;
        text-anchor: middle;
    }
    .yearLine {
        stroke: rgb(200,200,200);
        stroke-dasharray: 20,20;
    }
    
    .tooltip {display: none;}
    g:hover .tooltip {display: block;}
    </style>

      <xsl:call-template name="writeYearHeadings">
          <xsl:with-param name="start" select="@startYear" />
          <xsl:with-param name="num" select="@numYears" />
      </xsl:call-template>
      
      <rect
       width="{concat(@numYears * 12, 'cm')}"
       height="{concat(@lanes * 4, 'cm')}"
       style="fill:rgb(255,255,255); stroke-width: 4; stroke: rgb(60, 60, 60)"
       x="2cm" y="2cm" />

      <svg
       width="{concat(@numYears * 12, 'cm')}"
       height="{concat(@lanes * 4, 'cm')}" y="2cm">
        <xsl:call-template name="writeYearLines">
            <xsl:with-param name="num" select="@numYears" />
        </xsl:call-template>
        <xsl:apply-templates select="lane" />

      </svg>
    </svg>
  </xsl:template>

  <xsl:template name="writeYearHeadings">
    <xsl:param name="start" />
    <xsl:param name="num" />
    <xsl:param name="i" select="0" />
    <xsl:if test="$num > $i">
        <!-- generate a block -->
        <text class="year" x="{concat(7 + 12 * $i, 'cm')}" y="1.5cm"><xsl:value-of select="$start + $i" /></text>
        <!-- recursive call -->
        <xsl:call-template name="writeYearHeadings">
            <xsl:with-param name="num" select="$num"/>
            <xsl:with-param name="start" select="$start"/>
            <xsl:with-param name="i" select="$i + 1"/>
        </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="writeYearLines">
    <xsl:param name="num" />
    <xsl:param name="i" select="1" />
    <xsl:if test="$num > $i">
        <!-- generate a block -->
        <line x1="{concat($i * 12, 'cm')}" x2="{concat($i * 12, 'cm')}" y1="0.2cm" y2="37.8cm" class="yearLine" />
        <!-- recursive call -->
        <xsl:call-template name="writeYearLines">
            <xsl:with-param name="num" select="$num"/>
            <xsl:with-param name="i" select="$i + 1"/>
        </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lane">
    <svg height="14cm" width="100%" y="{concat(position() * 4 - 4, 'cm')}">
        <xsl:apply-templates select="event" />
        <xsl:apply-templates select="group" />
    </svg>
  </xsl:template>

  <xsl:template match="event">
    <xsl:variable name="xpos" select="(@year - $sy) * 12 + (@month - 1) + (@day - 1) * 0.0333" />
    <g>
      <rect width="3cm" height="3cm" y="1cm" x="{concat($xpos -1.5, 'cm')}" style="fill:rgb(255,255,255)" />
      <text x="{concat($xpos, 'cm')}" y="1.8cm" class="eventDate">
        <xsl:value-of select="@year" />-<xsl:value-of select="@month" />-<xsl:value-of select="@day" />
      </text>
      <foreignObject x="{concat($xpos - 1.5, 'cm')}" y="2.5cm" width="3cm" height="2.5cm">
        <p class="eventText" xmlns="http://www.w3.org/1999/xhtml"><xsl:value-of select="@title" /></p>
      </foreignObject>
      <rect width="1.5mm" height="6mm" style="fill:rgb(0,0,0);" y="2cm" x="{concat($xpos - 0.075, 'cm')}" />
      <foreignObject class="tooltip" x="{concat($xpos - 2, 'cm')}" y="3.5cm" width="6cm" height="10cm">
        <p xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates /></p>
      </foreignObject>
    </g>
  </xsl:template>

  <xsl:template match="group">
    <rect x="{concat((@startYear - $sy) * 12 + (@startMonth - 1), 'cm')}" y="2mm" width="{concat((@endYear - @startYear) * 12 + @endMonth - @startMonth - 0.4, 'cm')}" height="3.6cm" rx="2mm" ry="2mm" class="eventGroup" />
    <text x="{concat((@startYear - $sy) * 12 + (@startMonth - 1) + 0.4, 'cm')}" y="7mm" class="eventGroupDesc"><xsl:value-of select="@title" /></text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>  
  </xsl:template>
</xsl:stylesheet>