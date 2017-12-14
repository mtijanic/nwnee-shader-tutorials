//
// Transformations
//

// Model matrix for transformation from object space to world space
uniform mat4 m_m;

// ModelView matrix for transformation from object space to camera space
uniform mat4 m_mv;

// ModelViewProjection matrix for transformation from object space to screen space
uniform mat4 m_mvp;

// Untransformed normal matrix
uniform mat3 m_normal;

//
// Dynamic lighting
//

// Maximum dynamic lights supported by the engine
const int MAX_LIGHTS=8;

// Number of lights currently present (<= 8)
uniform int numLights;

uniform vec4 lightPosition          [MAX_LIGHTS];
uniform vec4 lightHalfVector        [MAX_LIGHTS];

uniform vec4 lightAmbient           [MAX_LIGHTS];
uniform vec4 lightDiffuse           [MAX_LIGHTS];
uniform vec4 lightSpecular          [MAX_LIGHTS];

uniform vec3 lightSpotDirection     [MAX_LIGHTS];
uniform float lightSpotExponent     [MAX_LIGHTS];
uniform float lightSpotCutoff       [MAX_LIGHTS];
uniform float lightSpotCosCutoff    [MAX_LIGHTS];
uniform float lightConstantAtten    [MAX_LIGHTS];
uniform float lightLinearAtten      [MAX_LIGHTS];
uniform float lightQuadraticAtten   [MAX_LIGHTS];

uniform vec4  materialFrontAmbient;
uniform vec4  materialFrontDiffuse;
uniform vec4  materialFrontSpecular;
uniform vec4  materialFrontEmissive;
uniform float materialFrontShininess;
uniform vec4 frontLightModelProductSceneColor;

//
// Fog
//
// Distance at which fog starts
uniform float fogStart;
// Distance at which fog ends
uniform float fogEnd;
// RGBA color of the fog
uniform vec4  fogColor;
// Fog mode: 0 = default, others currently unsupported
uniform int   fogMode;
// Is fog enabled? 0 means disabled
uniform int   fogEnabled;


//
// Screen resolution, in pixels
//
uniform int screenWidth;
uniform int screenHeight;

//
// Time
//

// Current frame
// - Increases with variable rate, depending on FPS
// - Keeps ticking while the game is paused
uniform int sceneCurrentFrame;

// A monotonically ticking timer with millisecond resolution
uniform int worldtimerTimeOfDay;

// In game calendar times, modifiable through nwscript
uniform int worldtimerYear;
uniform int worldtimerMonth;
uniform int worldtimerDay;
uniform int worldtimerHour;
uniform int worldtimerMinute;
uniform int worldtimerSecond;

// Module specific settings
uniform int moduleDawnHour;
uniform int moduleDuskHour;
uniform int moduleMinutesPerHour;


//
// Weather
//

// Current area bit-flags
#define NWAREA_FLAG_INTERIOR            0x0001
#define NWAREA_FLAG_UNDERGROUND         0x0002
#define NWAREA_FLAG_NATURAL             0x0004
uniform int areaFlags;

// Current area weather enum
#define NWAREA_WEATHER_CLEAR            0
#define NWAREA_WEATHER_RAIN             1
#define NWAREA_WEATHER_SNOW             2
uniform int areaWeatherType;

// Current area weather "density" - how much is it raining/snowing
uniform float areaWeatherDensity;

// X,Y,Z strength of the global wind
// Change in console with "setglobalwind x y z"
// Typically, X and Y are between 0.0 and 2.0, and Z is 0.0
uniform vec3 areaGlobalWind;

// Max number of wind point sources in the wind manager
const int MAX_WINDS=128;
// Actual number of wind point sources (<=128)
uniform int windPointSourcesCount;
// World space position of the winds
uniform vec3 windPointSourcesPosition[MAX_WINDS];
// World space radius of the wind source
uniform float windPointSourcesRadius[MAX_WINDS];
// Intensity of the wind source (Typically < 2.0)
uniform float windPointSourcesIntensity[MAX_WINDS];

// Missing: windPointSourcesTimeRemaining[MAX_WINDS]


//
// Input
//

// Screen pixel coordinates of the mouse
uniform ivec2 userinputMousePosition;

// Mouse buttons flags - set bit means currently pressed
#define MOUSE_BUTTON_LEFT   0x1
#define MOUSE_BUTTON_RIGHT  0x2
#define MOUSE_BUTTON_MIDDLE 0x4
uniform int userinputMouseButtons;



//
// FB effect variables
//

// Framebuffer containing already rendered scene
uniform sampler2D texUnit0;
// Framebuffer's depthbuffer. Only .x field is used.
uniform sampler2D texUnit1;

//
// Variables exposed to the NWScript console.
//   To query their value, just type the name in the console.
//   To set their value, type new value after the name
//
                           // NWN console names:
uniform float DOFAmount;   // dof_amount
uniform float Vibrance;    // vibrance_vibrance
uniform vec3 RGBBalance;   // vibrance_rgbbalance
uniform float AORadius;    // ssao_radius
uniform float AOIntensity; // ssao_intensity
uniform float AOColor;     // ssao_color
