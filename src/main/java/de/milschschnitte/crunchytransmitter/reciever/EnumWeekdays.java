package de.milschschnitte.crunchytransmitter.reciever;

import java.time.DayOfWeek;

public enum EnumWeekdays {
    MONDAY("Montag"),
    TUESDAY("Dienstag"),
    WEDNESDAY("Mittwoch"),
    THURSDAY("Donnerstag"),
    FRIDAY("Freitag"),
    SATURDAY("Samstag"),
    SUNDAY("Sonntag");

    private final String germanName;

    EnumWeekdays(String germanName) {
        this.germanName = germanName;
    }

    public String getGermanName() {
        return germanName;
    }

    public static EnumWeekdays fromGermanName(String germanName) {
        // Entfernen der zusätzlichen Anführungszeichen, falls vorhanden
        if (germanName.startsWith("\"") && germanName.endsWith("\"")) {
            germanName = germanName.substring(1, germanName.length() - 1);
        }
        
        for (EnumWeekdays day : values()) {
            if (day.getGermanName().equalsIgnoreCase(germanName)) {
                return day;
            }
        }
        return null;
    }

    public static DayOfWeek getDayOfWeek(EnumWeekdays enumWeekday) {
        switch (enumWeekday) {
            case MONDAY:
                return DayOfWeek.MONDAY;
            case TUESDAY:
                return DayOfWeek.TUESDAY;
            case WEDNESDAY:
                return DayOfWeek.WEDNESDAY;
            case THURSDAY:
                return DayOfWeek.THURSDAY;
            case FRIDAY:
                return DayOfWeek.FRIDAY;
            case SATURDAY:
                return DayOfWeek.SATURDAY;
            case SUNDAY:
                return DayOfWeek.SUNDAY;
            default:
                throw new IllegalArgumentException("Unbekannter Wochentag: " + enumWeekday);
        }
    }
}