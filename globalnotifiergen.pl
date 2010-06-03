print qq(/* THIS FILE WAS AUTOGENERATED BY GLOBALNOTIFIERGEN.PL --- DO NOT EDIT BY HAND!!! */\n\n);

my @vars = ();
foreach $file (@ARGV) {
    open(FILE, $file);

    while (<FILE>) {
      if (m|^\s*OWLVAR_([A-Z_0-9]+)\s*\(\s*"([^"]+)"\s*/\*\s*%OwlVarStub:?([a-z0-9_]+)?\s*\*/|) {   # "
        my $vartype = $1;
        my $varname = $2;
        my $altvarname = $2;
        $altvarname = $3 if ($3);

        my $propname = $altvarname;
        $propname =~ tr/a-z/A-Z/;
        $propname = "PROP_$propname";

        my $detailname = $altvarname;
        $detailname =~ s/[^a-zA-Z0-9]/-/g;
        $detailname =~ s/^[^a-zA-Z]+//;

        push @vars, {type => $vartype,
                     name => $varname,
                     altname => $altvarname,
                     propname => $propname,
                     detailname => $detailname};
      }
    }
    close(FILE);
}

print <<EOT;
#include "globalnotifier.h"
#include "owl.h"

/* properties */
enum {
  PROP_NONE,
  /* normal properties */
  PROP_RIGHTSHIFT,
  PROP_CURMSG,
  PROP_CURMSG_VERT_OFFSET,
  /* generated from variable listings */
EOT

for my $var (@vars) {
  print "  " . $var->{propname} . ",\n";
}

print <<EOT;
};

/* signals */
enum {
  VIEW_CHANGED,
  MESSAGE_RECEIVED,
  COMMAND_EXECUTED,
  LAST_SIGNAL
};

static guint notifier_signals[LAST_SIGNAL] = { 0 };

G_DEFINE_TYPE(OwlGlobalNotifier, owl_global_notifier, G_TYPE_OBJECT)

static void owl_global_notifier_set_property(GObject *object,
                                             guint property_id,
                                             const GValue *value,
                                             GParamSpec *pspec)
{
  OwlGlobalNotifier *notifier = OWL_GLOBAL_NOTIFIER(object);

  switch (property_id) {
    /* normal properties */
    case PROP_RIGHTSHIFT:
      owl_global_set_rightshift(notifier->g, g_value_get_int(value));
      break;
    case PROP_CURMSG:
      owl_global_set_curmsg(notifier->g, g_value_get_int(value));
      break;
    case PROP_CURMSG_VERT_OFFSET:
      owl_global_set_curmsg_vert_offset(notifier->g, g_value_get_int(value));
      break;
    /* generated from variable listings */
EOT

for my $var (@vars) {
    my $varname = $var->{name};
    my $propname = $var->{propname};
    print "    case $propname:\n";

    if ($var->{type} =~ /^BOOL/) {
      print <<EOT;
      if (g_value_get_boolean(value)) {
        owl_variable_set_bool_on(&notifier->g->vars, "$varname");
      } else {
        owl_variable_set_bool_off(&notifier->g->vars, "$varname");
      }
EOT
    } elsif ($var->{type} =~ /^PATH/ or $var->{type} =~ /^STRING/) {
      print "      owl_variable_set_string(&notifier->g->vars, \"$varname\", g_value_get_string(value));\n";
    } elsif ($var->{type} =~ /^INT/ or $var->{type} =~ /^ENUM/) {
      print "      owl_variable_set_int(&notifier->g->vars, \"$varname\", g_value_get_int(value));\n";
    } 
    print "      break;\n";
}

print <<EOT;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
  }
}

static void owl_global_notifier_get_property(GObject *object,
                                             guint property_id,
                                             GValue *value,
                                             GParamSpec *pspec)
{
  OwlGlobalNotifier *notifier = OWL_GLOBAL_NOTIFIER(object);

  switch (property_id) {
    /* normal properties */
    case PROP_RIGHTSHIFT:
      g_value_set_int(value, owl_global_get_rightshift(notifier->g));
      break;
    case PROP_CURMSG:
      g_value_set_int(value, owl_global_get_curmsg(notifier->g));
      break;
    case PROP_CURMSG_VERT_OFFSET:
      g_value_set_int(value, owl_global_get_curmsg_vert_offset(notifier->g));
      break;
    /* generated from variable listings */
EOT
for my $var (@vars) {
    my $varname = $var->{name};
    my $propname = $var->{propname};
    print "    case $propname:\n";

    if ($var->{type} =~ /^BOOL/) {
      print "      g_value_set_boolean(value, owl_variable_get_bool(&notifier->g->vars, \"$varname\"));\n";
    } elsif ($var->{type} =~ /^PATH/ or $var->{type} =~ /^STRING/) {
      print "      g_value_set_string(value, owl_variable_get_string(&notifier->g->vars, \"$varname\"));\n";
    } elsif ($var->{type} =~ /^INT/ or $var->{type} =~ /^ENUM/) {
      print "      g_value_set_int(value, owl_variable_get_int(&notifier->g->vars, \"$varname\"));\n";
    } 
    print "      break;\n";
}
print <<EOT;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(object, property_id, pspec);
  }
}

static void owl_global_notifier_class_init(OwlGlobalNotifierClass *klass)
{
  GObjectClass *gobject_class = G_OBJECT_CLASS(klass);
  GParamSpec *pspec;

  gobject_class->get_property = owl_global_notifier_get_property;
  gobject_class->set_property = owl_global_notifier_set_property;

  /* Create signals */

  notifier_signals[VIEW_CHANGED] =
    g_signal_new("view-changed",
                 G_TYPE_FROM_CLASS(gobject_class),
                 G_SIGNAL_RUN_FIRST,
                 0,
                 NULL, NULL,
                 g_cclosure_marshal_VOID__VOID,
                 G_TYPE_NONE,
                 0,
                 NULL);

  notifier_signals[MESSAGE_RECEIVED] =
    g_signal_new("message-received",
                 G_TYPE_FROM_CLASS(gobject_class),
                 G_SIGNAL_RUN_FIRST,
                 0,
                 NULL, NULL,
                 g_cclosure_marshal_VOID__POINTER,
                 G_TYPE_NONE,
                 1,
                 G_TYPE_POINTER, NULL);

  notifier_signals[COMMAND_EXECUTED] =
    g_signal_new("command-executed",
                 G_TYPE_FROM_CLASS(gobject_class),
                 G_SIGNAL_RUN_FIRST,
                 0,
                 NULL, NULL,
                 g_cclosure_marshal_VOID__VOID,
                 G_TYPE_NONE,
                 0,
                 NULL);

  /* Register properties */
  
  pspec = g_param_spec_int("rightshift",
                           "rightshift",
                           "How much we shift to the right",
                           0,
                           INT_MAX,
                           0,
                           G_PARAM_READABLE|G_PARAM_WRITABLE
                          |G_PARAM_STATIC_NAME|G_PARAM_STATIC_NICK|G_PARAM_STATIC_BLURB);
  g_object_class_install_property(gobject_class, PROP_RIGHTSHIFT, pspec);
  
  pspec = g_param_spec_int("curmsg",
                           "curmsg",
                           "The current message",
                           0,
                           INT_MAX,
                           0,
                           G_PARAM_READABLE|G_PARAM_WRITABLE
                          |G_PARAM_STATIC_NAME|G_PARAM_STATIC_NICK|G_PARAM_STATIC_BLURB);
  g_object_class_install_property(gobject_class, PROP_CURMSG, pspec);
  
  pspec = g_param_spec_int("curmsg-vert-offset",
                           "curmsg_vert_offset",
                           "How offset the current message is",
                           0,
                           INT_MAX,
                           0,
                           G_PARAM_READABLE|G_PARAM_WRITABLE
                          |G_PARAM_STATIC_NAME|G_PARAM_STATIC_NICK|G_PARAM_STATIC_BLURB);
  g_object_class_install_property(gobject_class, PROP_CURMSG_VERT_OFFSET, pspec);

EOT
for my $var (@vars) {
    my $varname = $var->{name};
    my $propname = $var->{propname};
    my $detailname = $var->{detailname};
    if ($var->{type} =~ /^BOOL/) {
      print <<EOT
  pspec = g_param_spec_boolean("$detailname",
                               "$varname",
                               "$varname", /* TODO: parse out the summary too */
                               FALSE,
                               G_PARAM_READABLE|G_PARAM_WRITABLE
                              |G_PARAM_STATIC_NAME|G_PARAM_STATIC_NICK|G_PARAM_STATIC_BLURB);
EOT
    } elsif ($var->{type} =~ /^PATH/ or $var->{type} =~ /^STRING/) {
      print <<EOT
  pspec = g_param_spec_string("$detailname",
                              "$varname",
                              "$varname", /* TODO: parse out the summary too */
                              "",
                              G_PARAM_READABLE|G_PARAM_WRITABLE
                             |G_PARAM_STATIC_NAME|G_PARAM_STATIC_NICK|G_PARAM_STATIC_BLURB);
EOT
    } elsif ($var->{type} =~ /^INT/ or $var->{type} =~ /^ENUM/) {
      print <<EOT
  pspec = g_param_spec_int("$detailname",
                           "$varname",
                           "$varname", /* TODO: parse out the summary too */
                           INT_MIN,
                           INT_MAX,
                           0,
                           G_PARAM_READABLE|G_PARAM_WRITABLE
                          |G_PARAM_STATIC_NAME|G_PARAM_STATIC_NICK|G_PARAM_STATIC_BLURB);
EOT
    } 
    print "  g_object_class_install_property(gobject_class, $propname, pspec);\n\n";
}
print <<EOT;
}

static void owl_global_notifier_init(OwlGlobalNotifier *self)
{
}

OwlGlobalNotifier *owl_global_notifier_new(owl_global *g)
{
  OwlGlobalNotifier *gn;
  
  gn = g_object_new(OWL_TYPE_GLOBAL_NOTIFIER, NULL);
  gn->g = g;
  return gn;
}

void owl_global_notifier_emit_view_changed(OwlGlobalNotifier *gn)
{
  g_signal_emit(gn, notifier_signals[VIEW_CHANGED], 0);
}

void owl_global_notifier_emit_message_received(OwlGlobalNotifier *gn, owl_message *msg)
{
  g_signal_emit(gn, notifier_signals[MESSAGE_RECEIVED], 0, msg);
}

void owl_global_notifier_emit_command_executed(OwlGlobalNotifier *gn)
{
  g_signal_emit(gn, notifier_signals[COMMAND_EXECUTED], 0);
}

EOT
