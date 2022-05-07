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
  <xsl:variable name="lanes" select="timeline/@lanes" />
  
  <xsl:template match="timeline">
    <svg xmlns="http://www.w3.org/2000/svg" width="{concat(8 + @numYears * 12, 'cm')}" height="{concat(4 + @lanes * 4, 'cm')}" >
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

    .eventMarker {
      fill: rgb(0,0,0);
    }
    .eventMarker:hover {
      fill: rgb(0,0,255);
    }
    
    <xsl:apply-templates select="//event" mode="stylesheet" />
    </style>

      <xsl:call-template name="writeYearHeadings">
          <xsl:with-param name="start" select="@startYear" />
          <xsl:with-param name="num" select="@numYears" />
      </xsl:call-template>
      
      <rect
       width="{concat(@numYears * 12 + 4, 'cm')}"
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
        <xsl:apply-templates select="lane" mode="overlay" />

      </svg>
    </svg>
  </xsl:template>

  <xsl:template name="writeYearHeadings">
    <xsl:param name="start" />
    <xsl:param name="num" />
    <xsl:param name="i" select="0" />
    <xsl:if test="$num > $i">
        <!-- generate a block -->
        <text class="year" x="{concat(10 + 12 * $i, 'cm')}" y="1.5cm"><xsl:value-of select="$start + $i" /></text>
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
    <xsl:param name="i" select="0" />
    <xsl:if test="$num >= $i">
        <!-- generate a block -->
        <line x1="{concat($i * 12 + 4, 'cm')}" x2="{concat($i * 12 + 4, 'cm')}" y1="0.2cm" y2="{concat($lanes * 4 - 0.2, 'cm')}" class="yearLine" />
        <!-- recursive call -->
        <xsl:call-template name="writeYearLines">
            <xsl:with-param name="num" select="$num"/>
            <xsl:with-param name="i" select="$i + 1"/>
        </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="lane">
    <xsl:apply-templates select="event">
      <xsl:with-param name="ypos"><xsl:value-of select="position() * 4 - 4" /></xsl:with-param>
    </xsl:apply-templates>
    <xsl:apply-templates select="group">
      <xsl:with-param name="ypos"><xsl:value-of select="position() * 4 - 4" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="lane" mode="overlay">
    <xsl:apply-templates select="event" mode="overlay">
      <xsl:with-param name="ypos"><xsl:value-of select="position() * 4 - 4" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="event">
    <xsl:param name="ypos" />
    <xsl:variable name="xpos" select="(@year - $sy) * 12 + (@month - 1) + (@day - 1) * 0.0333 + 4" />
    <g class="{generate-id(.)}">
      <xsl:choose>
        <xsl:when test="@minor">
          <circle class="eventMarker" cx="{concat($xpos, 'cm')}" cy="{concat($ypos + 2.35, 'cm')}" r="1.5mm" />
        </xsl:when>
        <xsl:otherwise>
          <rect width="3cm" height="3cm" y="{concat($ypos + 1, 'cm')}" x="{concat($xpos -1.5, 'cm')}" style="fill:rgb(255,255,255)" />
          <rect width="1.5mm" height="6mm" class="eventMarker" y="{concat($ypos + 2, 'cm')}" x="{concat($xpos - 0.075, 'cm')}" />
          <text x="{concat($xpos, 'cm')}" y="{concat($ypos + 1.8, 'cm')}" class="eventDate">
            <xsl:value-of select="@year" />-<xsl:value-of select="@month" />-<xsl:value-of select="@day" />
          </text>
          <foreignObject x="{concat($xpos - 1.5, 'cm')}" y="{concat($ypos + 2.5, 'cm')}" width="3cm" height="2.5cm">
            <p class="eventText" xmlns="http://www.w3.org/1999/xhtml"><xsl:value-of select="@title" /></p>
          </foreignObject>
        </xsl:otherwise>
      </xsl:choose>
    </g>
  </xsl:template>

  <xsl:template match="event" mode="overlay">
    <xsl:param name="ypos" />
    <xsl:variable name="xpos" select="(@year - $sy) * 12 + (@month - 1) + (@day - 1) * 0.0333 + 2" />
    <foreignObject id="{generate-id(.)}" class="{concat('tooltip ', generate-id(.))}" x="{concat($xpos - 2, 'cm')}" y="{concat($ypos + 3.5, 'cm')}" width="6cm" height="10cm">
      <xsl:if test="@minor">
        <p xmlns="http://www.w3.org/1999/xhtml"><xsl:value-of select="@year" />-<xsl:value-of select="@month" />-<xsl:value-of select="@day" /></p>
      </xsl:if>
      <p xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates /></p>
    </foreignObject>
  </xsl:template>

  <xsl:template match="event" mode="stylesheet">
    .<xsl:value-of select="generate-id(.)" />:hover ~ #<xsl:value-of select="generate-id(.)" />.tooltip {
      display: block;
      background-color: White;
    }
  </xsl:template>

  <xsl:template match="group">
    <xsl:param name="ypos" />
    <rect x="{concat((@startYear - $sy) * 12 + (@startMonth - 1) + 2.2, 'cm')}" y="{concat($ypos + 0.2, 'cm')}" width="{concat((@endYear - @startYear) * 12 + @endMonth - @startMonth + 0.6, 'cm')}" height="3.6cm" rx="2mm" ry="2mm" class="eventGroup" />
    <text x="{concat((@startYear - $sy) * 12 + (@startMonth - 1) + 2.4, 'cm')}" y="{concat($ypos + 0.7, 'cm')}" class="eventGroupDesc"><xsl:value-of select="@title" /></text>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>  
  </xsl:template>
</xsl:stylesheet>