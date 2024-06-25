package de.milschschnitte.crunchytransmitter.reciever;

import java.time.DayOfWeek;
import java.util.Calendar;
import java.util.Date;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public enum EnumWeekdays {
    MONDAY("Montag"),
    TUESDAY("Dienstag"),
    WEDNESDAY("Mittwoch"),
    THURSDAY("Donnerstag"),
    FRIDAY("Freitag"),
    SATURDAY("Samstag"),
    SUNDAY("Sonntag");

    private final String germanName;
    static Logger logger = LogManager.getLogger(EnumWeekdays.class);

    EnumWeekdays(String germanName) {
        this.germanName = germanName;
    }

    public String getGermanName() {
        return germanName;
    }

    public static EnumWeekdays fromGermanName(String germanName) {
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
                logger.warn("Unknown weekday: " + enumWeekday);
                throw new RuntimeException();
        }
    }

    public static boolean isInCurrentWeek(Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        int currentWeek = calendar.get(Calendar.WEEK_OF_YEAR);

        Calendar today = Calendar.getInstance();
        int currentYear = today.get(Calendar.YEAR);
        int currentWeekOfYear = today.get(Calendar.WEEK_OF_YEAR);

        return calendar.get(Calendar.YEAR) == currentYear && currentWeek == currentWeekOfYear;
    }
}
